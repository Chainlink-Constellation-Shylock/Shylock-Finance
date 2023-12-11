// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import "../test/mock/ERC20Mock.sol";
import "../src/compound/Unitroller.sol";
import "../src/compound/JumpRateModelV2.sol";
import "../src/compound/SimplePriceOracle.sol";
import "../src/ShylockComptroller.sol";
import "../src/ShylockCErc20.sol";
import { ShylockGovernance } from "../src/ShylockGovernance.sol";
import { MockConsumer } from "../test/mock/MockConsumer.sol";


contract ShylockDeploy is Script {
    address owner;
    string constant main = "fuji";
    string constant sub = "sepolia";
    mapping(string => uint) rpcIndex;

    ShylockGovernanceInterface.DaoInfo public daoInfo;

    // on Main Chain
    ERC20Mock mockERC20_main;
    ShylockCErc20 shERC20;
    Unitroller unitroller;
    JumpRateModelV2 interestRateModel;
    SimplePriceOracle priceOracle;
    MockConsumer consumer;
    ShylockGovernance governance;
    address dao;
    address member;

    // on Sub Chain
    ERC20Mock mockERC20_sub;


    function setUp() public {
        string memory fujiRPC = "https://api.avax-test.network/ext/bc/C/rpc";
        string memory sepoliaRPC = "https://rpc.sepolia.org";

        rpcIndex["fuji"] = vm.createFork(fujiRPC);
        rpcIndex["sepolia"]= vm.createFork(sepoliaRPC);

        // do initial setup what we need
        // mockERC20_main = mockERC20_main("0x000...");

        owner = vm.addr(vm.envUint("PRIVATE_KEY"));
        console.log("owner: ", owner);
        member = owner;
        dao = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        uint256[] memory weights = new uint256[](1); 
        weights[0] = 100;
        address[] memory dataOrigins = new address[](1);
        // dataOrigins[0] = address(consumer);
        daoInfo = ShylockGovernanceInterface.DaoInfo({
            daoName: "MockDao",
            tierThreshold: 2,
            numberOfTiers: 4,
            daoCap: 100 * 1e18,
            protocolToDaoGuaranteeRate: 1e18,
            reputation: 5000,
            weights: weights,
            dataOrigins: dataOrigins
        });

    }

    function deployOurMockERC20(string memory name, string memory symbol) public returns (ERC20Mock) {
        ERC20Mock _mock = new ERC20Mock();
        _mock.initialize(name, symbol);
        console.log("mockERC20 deployed: ", address(_mock));
        return _mock;
    }

    function deployUnitroller() public returns (Unitroller)  {
        Comptroller _comptroller = new ShylockComptroller();
        Unitroller _unitroller = new Unitroller();

        _unitroller._setPendingImplementation(address(_comptroller));
        _comptroller._become(_unitroller);

        console.log("unitroller deployed: ", address(_unitroller));
        return _unitroller;
    }

    function deployPriceOracle() public returns (SimplePriceOracle) {
        // we need change this to our price oracle
        SimplePriceOracle _priceOracle = new SimplePriceOracle();
        
        console.log("priceOracle deployed: ", address(_priceOracle));
        return _priceOracle;
    }
    
    function deployGovernonce() public returns (ShylockGovernance) {
        require(address(unitroller) != address(0), "unitroller is not deployed yet");
        ShylockGovernance _governance = new ShylockGovernance(owner, address(unitroller));

        console.log("governance deployed: ", address(_governance));
        return _governance;
    }

    function deployMockConsumer() public returns (MockConsumer) {
        MockConsumer _mockConsumer = new MockConsumer();

        console.log("mockConsumer deployed: ", address(_mockConsumer));
        return _mockConsumer;
    }

    function deployShERC20(uint initialExchangeRateMantissa_, string memory name, string memory symbol, uint8 deimal) public returns (ShylockCErc20) {
        require(address(mockERC20_main) != address(0), "mockERC20_main is not deployed yet");
        require(address(unitroller) != address(0), "unitroller is not deployed yet");
        require(address(interestRateModel) != address(0), "interestRateModel is not deployed yet");
        require(address(owner) != address(0), "owner is not set");

        ShylockCErc20 _shERC20 = new ShylockCErc20(
            address(mockERC20_main),
            ShylockComptrollerInterface(address(unitroller)),
            interestRateModel,
            initialExchangeRateMantissa_,
            name,
            symbol,
            deimal,
            payable(owner)
        );
        ComptrollerInterface(address(unitroller))._supportMarket(CToken(address(_shERC20)));

        console.log("shERC20 deployed: ", address(_shERC20));
        return _shERC20;
    }

    function run() external {
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
