// // SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {console2} from "lib/forge-std/src/console2.sol";
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_GetterTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testCorrectness_Asset() external {
    assertEq(address(ybeth.asset()), address(weth));
  }

  function testCorrectness_MaxDeposit() external {
    assertEq(ybeth.maxDeposit(address(this)), type(uint256).max);
  }

  function testCorrectness_MaxMint() external {
    assertEq(ybeth.maxMint(address(this)), type(uint256).max);
  }

  function testCorrectness_MaxWithdraw() external {
    assertEq(ybeth.maxWithdraw(address(this)), 0);

    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    assertEq(ybeth.maxWithdraw(address(this)), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    // Next user deposit to ybETH
    vm.startPrank(alice);
    // Deal and mint 1_000 weth
    vm.deal(alice, 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, alice);
    vm.stopPrank();

    assertEq(ybeth.maxWithdraw(address(this)), 1039996000399960003999);
    assertApproxEqAbs(ybeth.maxWithdraw(alice), 1_000 ether, 1);
  }

  function testCorrectness_MaxWithdraw_WhenUnclaimedYield() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    assertEq(ybeth.maxWithdraw(address(this)), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    assertEq(ybeth.maxWithdraw(address(this)), 1039996000399960003999);
  }

  function testCorrectness_MaxRedeem() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    assertEq(ybeth.maxRedeem(address(this)), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    // Next user deposit to ybETH
    vm.startPrank(alice);
    // Deal and mint 1_000 weth
    vm.deal(alice, 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, alice);
    vm.stopPrank();

    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    assertEq(ybeth.maxRedeem(address(this)), 1_000 ether);
    assertEq(ybeth.maxRedeem(alice), _expectedAliceShares);
  }

  function testCorrectness_PreviewDeposit_WhenUnclaimedYield() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    uint256 _expectedShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    assertEq(ybeth.previewDeposit(1_000 ether), _expectedShares);
  }

  function testCorrectness_PreviewRedeem_WhenUnclaimedYield() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    assertEq(ybeth.previewRedeem(1_000 ether), 1039996000399960003999);
  }

  function testCorrectness_PreviewMint_WhenUnclaimedYield() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    uint256 _expectedShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    assertEq(ybeth.previewMint(_expectedShares), 1_000 ether);
  }
}
