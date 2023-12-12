// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/crosschain/CcipGateway.sol";
import "../src/crosschain/CTokenPool.sol";

import "./ShylockDeploy.s.sol";


contract ShylockCrossDeploy is ShylockDeploy {
  
    CcipGateway ccipGateWay_main;
    CcipGateway ccipGateWay_sub;

    function setUp() override public {
        super.setUp();
       
        // do initial setup what we need
        // mockERC20_main = mockERC20_main("0x000...");'

        // mockERC20 deployed:  0xF0452f5cB881C3fF5f8E81dD6De7ACB6E1df4375
        // unitroller deployed:  0x889035B48230ADbb630F7Ca9F673e4A72C87e9dd
        // shERC20 deployed:  0xE3777aCccBa34F04E1cb9e05D16644F60CbCb489
        // priceOracle deployed:  0xf14Bc9E9b4f8edADF2A69cc99B8FF194e3e536C1
        // mockConsumer deployed:  0xE4B67C256C0E16909684f8454b21b3224ecA577f
        // governance deployed:  0x553B8D63EaFB879B5cAcF59aE4E086e852742220
        // dao address:  0x7878099b167Abed0eB458727dCFe82200E4f7123

    }

    function deployShERC20(uint initialExchangeRateMantissa_, string memory name, string memory symbol, uint8 deimal) override public returns (ShylockCErc20) {
        require(address(mockERC20_main) != address(0), "mockERC20_main is not deployed yet");
        require(address(unitroller) != address(0), "unitroller is not deployed yet");
        require(address(interestRateModel) != address(0), "interestRateModel is not deployed yet");
        require(address(owner) != address(0), "owner is not set");

        ShylockCErc20Crosschain _shERC20 = new ShylockCErc20Crosschain(
            address(mockERC20_main),
            ShylockComptrollerInterface(address(unitroller)),
            interestRateModel,
            initialExchangeRateMantissa_,
            name,
            symbol,
            deimal,
            payable(owner),
            address(ccipGateWay_main)
        );
        ComptrollerInterface(address(unitroller))._supportMarket(CToken(address(_shERC20)));

        console.log("shERC20Crosschain deployed: ", address(_shERC20));
        return _shERC20;
    }

    function run() override external {
        console.log("#### On Main Chain ####");
        vm.selectFork(rpcIndex[main]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // deploy and initialize shylockCompound contracts
        mockERC20_main = address(mockERC20_main) != address(0) ? mockERC20_main : deployOurMockERC20("DAI", "DAI");
        unitroller = address(unitroller) != address(0) ? unitroller : deployUnitroller();
        if(address(priceOracle) == address(0)){
            priceOracle = deployPriceOracle();
            priceOracle.setDirectPrice(address(mockERC20_main), 0.00042*10**18);
            ShylockComptrollerInterface(address(unitroller))._setPriceOracle(priceOracle);
        }
    
        interestRateModel = address(interestRateModel) != address(0) ? interestRateModel :  new JumpRateModelV2(1, 1, 1, 100, owner);
        shERC20 = address(shERC20) != address(0) ? shERC20 : deployShERC20(1e18, "shDAI", "shDAI", 8);

        // deploy and initialize governance contract
        if(address(consumer) == address(0)){
            consumer = deployMockConsumer();
            consumer.setScore(daoInfo.daoName, member, 60);
            daoInfo.dataOrigins[0] = address(consumer);
        }
        if(address(governance) == address(0)){
            governance = deployGovernonce();
            governance.registerDao(
                dao,
                daoInfo.daoName,
                daoInfo.tierThreshold,
                daoInfo.numberOfTiers,
                daoInfo.daoCap,
                daoInfo.weights,
                daoInfo.dataOrigins
            );
            governance.getMemberCap(dao, member);
            ShylockComptrollerInterface(address(unitroller)).setGovernanceContract(governance);
        }
      
        vm.stopBroadcast();

        console.log("");
        console.log("#### On Sub Chain ####");
        vm.selectFork(rpcIndex[sub]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        mockERC20_sub = address(mockERC20_sub) != address(0) ? mockERC20_sub : deployOurMockERC20("DAI", "DAI");
        vm.stopBroadcast();
    }
}
