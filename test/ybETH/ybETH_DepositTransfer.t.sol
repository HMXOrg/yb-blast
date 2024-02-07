// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_DepositTransferTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenPrecisionLoss() external {
    // Assuming someone deposit but won't get any share
    // due to precision loss.
    // Deal 1_000 ETH
    vm.deal(address(this), 1_000 ether);
    // Deposit to ybETH via deposit ETH
    address(ybeth).safeTransferETH(1_000 ether);
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether);

    // Assuming we have a large pending yields
    // which then inflated the share value.
    weth.setNextYield(120_000_000 ether);
    ybeth.claimAllYield();

    // Now share value of ybETH is extremely expensive.
    // 1 ybETH = 120_001_000 / 1_000 = 120_001 weth
    // Next user deposit small WETH to ybETH
    vm.startPrank(alice);
    // Deal and mint 1 wei of weth
    vm.deal(alice, 1 wei);
    // Deposit to ybETH via deposit ETH
    vm.expectRevert(abi.encodeWithSignature("ZeroShares()"));
    address(ybeth).safeTransferETH(1 wei);
    vm.stopPrank();
  }

  function testCorrectness_WhenDepositETHSuccessfully() external {
    // Deal 1_000 ETH
    vm.deal(address(this), 1_000 ether);
    // Deposit to ybETH via DepositETH
    address(ybeth).safeTransferETH(1_000 ether);
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    weth.setNextYield(40 ether);

    // Next user deposit to ybETH
    vm.startPrank(alice);
    // Deal 1_000 ETH
    vm.deal(alice, 1_000 ether);
    // Deposit to ybETH
    address(ybeth).safeTransferETH(1_000 ether);
    vm.stopPrank();
    // Assert
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    assertEq(ybeth.balanceOf(alice), _expectedAliceShares);
    assertEq(ybeth.totalAssets(), 2_040 ether);
    assertEq(weth.balanceOf(address(ybeth)), 2_040 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether + _expectedAliceShares);
  }
}
