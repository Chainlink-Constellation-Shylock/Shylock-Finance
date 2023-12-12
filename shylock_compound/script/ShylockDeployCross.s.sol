// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/crosschain/CcipGateway.sol";
import "../src/crosschain/CTokenPool.sol";
import "../src/ShylockCErc20Crosschain.sol";

import "./ShylockDeploy.s.sol";


contract ShylockDeployCross is ShylockDeploy {
    
    ShylockCErc20Crosschain shERC20Cross;
    CcipGateway ccipGateWay_main;
    CcipGateway ccipGateWay_sub;
    CTokenPool cTokenPool;

    address fujiRouter = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
    uint64 fujiChainSelector = 14767482510784806043;
    address fujiLinkToken = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    address sepoliaRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    uint64 sepoliaChainSelector = 16015286601757825753;
    address sepoliaLinkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;



    function setUp() override public {
        super.setUp();
       
        // do initial setup what we need
        // mockERC20_main = mockERC20_main("0x000...");'

        // #### On Main Chain ####
        // mockERC20 deployed:  0x5b5282a01d0550aF62b3Ef83a437A72efBD68358
        // unitroller deployed:  0xF407f4Aa43E88be166AF4A2ee8b23f6b99Ea7d2a
        // shERC20Crosschain deployed:  0xc794Ae47dccf094253785334b987f081D8f7151F
        // priceOracle deployed:  0x37037c9fF8b98919CC5e6852d017263B61242357
        // mockConsumer deployed:  0xa18fD67BD803AA58C84F1fA4907555888C2746b7
        // governance deployed:  0xbD828A6D4f6D3d95961b6A76e7970c75E16f5513
        // dao address:  0x98442AEE6fA0D6cfee1c946D05b237bB8235edec
        // mockERC20_main My balance:  1000000000000000000000000
        // mockERC20_main DAO sbalance:  100000000000000000000000

        // #### On Sub Chain ####
        // mockERC20 deployed:  0x70984CfeFAc3AC8d945d945465E99406072088Fe
        // ccipGateWay deployed:  0x8870d4f43eA17FBdec41337EEa8C7A10De9D9413
        // CTokenPool deployed:  0xea7d255b38d083A784fdD784c621dC9178B3969A
        // set ccipGateWay_sub fromToConnection:  0x04f966e6a94917f4087a1c3D7E2c4f64F2562788 0xea7d255b38d083A784fdD784c621dC9178B3969A

        // #### On Main Chain ####
        // set shERC20Cross DestGateWay:  0xea7d255b38d083A784fdD784c621dC9178B3969A
        // set ccipGateWay_main fromToConnection:  0x8870d4f43eA17FBdec41337EEa8C7A10De9D9413 0xc794Ae47dccf094253785334b987f081D8f7151F

        
        // mockERC20_main = ERC20Mock(0x5b5282a01d0550aF62b3Ef83a437A72efBD68358);
        // unitroller = Unitroller(payable(0xF407f4Aa43E88be166AF4A2ee8b23f6b99Ea7d2a));
        // shERC20Cross = ShylockCErc20Crosschain(0xc794Ae47dccf094253785334b987f081D8f7151F);
        // priceOracle = ShylockOracle(0x37037c9fF8b98919CC5e6852d017263B61242357);
        // consumer = MockConsumer(0xa18fD67BD803AA58C84F1fA4907555888C2746b7);
        // governance = ShylockGovernance(payable(0xbD828A6D4f6D3d95961b6A76e7970c75E16f5513));
        // dao = address(0x98442AEE6fA0D6cfee1c946D05b237bB8235edec);
        
        
        // mockERC20_sub = ERC20Mock(0x70984CfeFAc3AC8d945d945465E99406072088Fe);
        

    }

    function deployCCIPGateway(address router, address _linkToken, uint64 _destinationChainSelector) public returns (CcipGateway) {
        CcipGateway _ccipGateWay = new CcipGateway(router, _linkToken, _destinationChainSelector);
        
        console.log("ccipGateWay deployed: ", address(_ccipGateWay));
        return _ccipGateWay;
    }

    function deployShERC20Cross(uint initialExchangeRateMantissa_, string memory name, string memory symbol, uint8 deimal) public returns (ShylockCErc20Crosschain) {
        require(address(mockERC20_main) != address(0), "mockERC20_main is not deployed yet");
        require(address(unitroller) != address(0), "unitroller is not deployed yet");
        require(address(interestRateModel) != address(0), "interestRateModel is not deployed yet");
        require(address(owner) != address(0), "owner is not set");
        require(address(ccipGateWay_main) != address(0), "ccipGateWay_main is not deployed yet");

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

    function deployCTokenPool(address _cToken) public returns (CTokenPool) {
        require(address(mockERC20_sub) != address(0), "mockERC20_sub is not deployed yet");
        require(address(ccipGateWay_sub) != address(0), "ccipGateWay_sub is not deployed yet");
        require(address(ccipGateWay_main) != address(0), "shERC20Cross is not deployed yet");
        CTokenPool _cTokenPool = new CTokenPool(address(mockERC20_sub), address(ccipGateWay_main), ccipGateWay_sub);

        console.log("CTokenPool deployed: ", address(_cTokenPool));
        return _cTokenPool;
    }


    function run() override external {
        console.log("#### On Main Chain ####");
        vm.selectFork(rpcIndex[main]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // deploy and initialize shylockCompound contracts
        mockERC20_main = address(mockERC20_main) != address(0) ? mockERC20_main : deployOurMockERC20("DAI", "DAI");
        unitroller = address(unitroller) != address(0) ? unitroller : deployUnitroller();
        
        ccipGateWay_main = address(ccipGateWay_main) != address(0) ? ccipGateWay_main : deployCCIPGateway(fujiRouter, fujiLinkToken, sepoliaChainSelector);
    
        interestRateModel = address(interestRateModel) != address(0) ? interestRateModel :  new JumpRateModelV2(1, 1, 1, 100, owner);
        shERC20Cross = address(shERC20Cross) != address(0) ? shERC20Cross : deployShERC20Cross(2 ** 18, "shDAI", "shDAI", 8);
        if(address(priceOracle) == address(0)){
            priceOracle = deployPriceOracle(address(shERC20Cross));
            ShylockComptrollerInterface(address(unitroller))._setPriceOracle(priceOracle);
        }
        // deploy and initialize governance contract
        if(address(consumer) == address(0)){
            consumer = deployMockConsumer();
            daoInfo.dataOrigins[0] = address(consumer);
        }
        if (address(mockDao) == address(0)) {
            mockDao = new MockDao();
            dao = address(mockDao);
        }
        if(address(governance) == address(0)){
            governance = deployGovernonce();
            console.log("dao address: ", dao);
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
        // governance.getMemberCap(dao, member);

        // initial dao setup
        mockERC20_main.mint(owner, 1_000_000 * 1e18);
        mockERC20_main.mint(address(mockDao), 100_000 * 1e18);
        console.log("mockERC20_main My balance: ", mockERC20_main.balanceOf(owner));
        console.log("mockERC20_main DAO sbalance: ", mockERC20_main.balanceOf(address(mockDao)));
        // Approval
        mockDao.execute(
            address(mockERC20_main), 
            abi.encodeWithSignature("approve(address,uint256)", address(shERC20Cross), 100_000 * 1e18)
        );
        mockDao.addDaoReserve(address(shERC20Cross), 10 * 1e18);
        shERC20Cross.addMemberReserve(dao, 10 * 1e18);
      
        // send 0.1 LINK
        if(ERC20Mock(fujiLinkToken).balanceOf(address(ccipGateWay_main)) == 0){
            ERC20Mock(fujiLinkToken).approve(address(ccipGateWay_main), 100000000000000000);
            ERC20Mock(fujiLinkToken).transfer(address(ccipGateWay_main), 100000000000000000); 
        }
       
        
        
        vm.stopBroadcast();



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        console.log("");
        console.log("#### On Sub Chain ####");
        vm.selectFork(rpcIndex[sub]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        mockERC20_sub = address(mockERC20_sub) != address(0) ? mockERC20_sub : deployOurMockERC20("DAI", "DAI");
        ccipGateWay_sub = address(ccipGateWay_sub) != address(0) ? ccipGateWay_sub : deployCCIPGateway(sepoliaRouter, sepoliaLinkToken, fujiChainSelector);
        cTokenPool = address(cTokenPool) != address(0) ? cTokenPool : deployCTokenPool(address(shERC20Cross));
      
        // send 0.1 LINK
        if(ERC20Mock(sepoliaLinkToken).balanceOf(address(ccipGateWay_sub)) == 0){
            ERC20Mock(sepoliaLinkToken).approve(address(ccipGateWay_sub), 100000000000000000);
            ERC20Mock(sepoliaLinkToken).transfer(address(ccipGateWay_sub), 100000000000000000); 
        }

        ccipGateWay_sub.setFromToConnection(address(ccipGateWay_main), address(cTokenPool));
        console.log("set ccipGateWay_sub fromToConnection: ", address(ccipGateWay_main), address(cTokenPool));

        vm.stopBroadcast();

        
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        
        console.log("");
        console.log("#### On Main Chain ####");
        vm.selectFork(rpcIndex[main]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));


        shERC20Cross.setDestGateWay(address(ccipGateWay_sub));
        console.log("set shERC20Cross DestGateWay: ", address(ccipGateWay_sub));
        ccipGateWay_main.setFromToConnection(address(ccipGateWay_sub), address(shERC20Cross));
        console.log("set ccipGateWay_main fromToConnection: ", address(ccipGateWay_sub), address(shERC20Cross));

        vm.stopBroadcast();

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        console.log("");
        console.log("#### On Sub Chain ####");
        vm.selectFork(rpcIndex[sub]);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));


        mockERC20_sub.mint(owner, 1_000_000 * 1e18);
        console.log("mockERC20_sub My balance: ", mockERC20_sub.balanceOf(owner));
        mockERC20_sub.approve(address(cTokenPool), 10 * 1e18);
        // cTokenPool.addMemberReserve(dao, 10 * 1e18);


    }
}
