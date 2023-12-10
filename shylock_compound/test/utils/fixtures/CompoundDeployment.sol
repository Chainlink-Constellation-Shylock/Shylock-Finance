// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../../src/compound/CTokenInterfaces.sol";
// import "../../../src/compound/CErc20Delegate.sol";
// import "../../../src/compound/CErc20Delegator.sol";
import "../../../src/compound/Unitroller.sol";
import "../../../src/compound/JumpRateModelV2.sol";
import "../../../src/compound/CEther.sol";
import "../../../src/ShylockComptroller.sol";
import "../../../src/ShylockCErc20.sol";

import "../../utils/fixtures/ERC20Fixtures.sol";
// import "../../mock/CERC20Mock.sol";
import "../../mock/CEtherMock.sol";

import "forge-std/Test.sol";

// deploy & initializes bCompound Contracts
contract CompoundDeployment is Test, ERC20Fixtures {
    ShylockCErc20 sDAI;
    CEther sETH;
    CToken cToken;
    CToken cEther;
    ShylockComptroller comptroller;
    Unitroller unitroller;
    JumpRateModelV2 interestRateModel;

    bool internal BDAI = false;

    function setUp() public virtual override {
        super.setUp();

        try vm.envBool("BDAI") returns (bool isBDai) {
            BDAI = isBDai;
        } catch (bytes memory) {
            // This catches revert that occurs if env variable not supplied
        }

        vm.startPrank(owner);

        comptroller = new ShylockComptroller();
        unitroller = new Unitroller();
        interestRateModel = new JumpRateModelV2(1, 1, 1, 100, owner);

        unitroller._setPendingImplementation(address(comptroller));

        comptroller._become(unitroller);
        // ComptrollerInterface(address(unitroller))._setSeizePaused(true);

        // deploy and initialize implementation contracts
        // cTokenImplementation = new CErc20Delegate();

        // deploy cTokenDelegator
        // bDAI = new CErc20Delegator(
        //     address(daiToken),
        //     ShylockComptrollerInterface(address(unitroller)),
        //     interestRateModel,
        //     2**18,
        //     "niftyApesWrappedXDai",
        //     "bwxDai",
        //     8,
        //     owner,
        //     address(cTokenImplementation),
        //     bytes("")
        // );

        // constructor(address underlying_,
        //     ShylockComptrollerInterface comptroller_,
        //     InterestRateModel interestRateModel_,
        //     uint initialExchangeRateMantissa_,
        //     string memory name_,
        //     string memory symbol_,
        //     uint8 decimals_,
        //     address payable admin_,
        //     address ccipGateWay_)

        address ccipGateWay = address(0);

        sDAI = new ShylockCErc20(
            address(daiToken),
            ShylockComptrollerInterface(address(unitroller)),
            interestRateModel,
            2**18,
            "ShylockFinanceDai",
            "SFDAI",
            8,
            owner
        );


        // deploy cETH
        sETH = new CEther(
            ShylockComptrollerInterface(address(unitroller)),
            interestRateModel,
            2**18,
            "ShylockFinanceEther",
            "SFETH",
            8,
            owner
        );

        // declare interfaces
        cToken = CToken(address(sDAI));
        cEther = CToken(address(sETH));

        ComptrollerInterface(address(unitroller))._supportMarket(cToken);
        ComptrollerInterface(address(unitroller))._supportMarket(cToken);
        // ComptrollerInterface(address(unitroller))._setBorrowPaused(cToken, true);

        if (BDAI) {
            cDAIToken = CERC20Mock(address(sDAI));
            // liquidity.setCAssetAddress(address(daiToken), address(cDAIToken));
            // liquidity.setMaxCAssetBalance(address(cDAIToken), ~uint256(0));

            cEtherToken = CEtherMock(address(sETH));
            // liquidity.setCAssetAddress(address(ETH_ADDRESS), address(cEtherToken));
            // liquidity.setMaxCAssetBalance(address(cEtherToken), ~uint256(0));
        }

        vm.stopPrank();

        vm.label(address(0), "NULL !!!!! ");
    }
}