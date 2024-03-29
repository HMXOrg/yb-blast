// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_WithdrawETHTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenWithdrawETHSuccessfully() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000.1 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000.1 ether);
    assertEq(ybeth.totalSupply(), 1_000.1 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next redeem is called, the 1st user should received correct amount of WETH.
    weth.setNextYield(40 ether);

    // Alice deposit 1_000 weth to ybETH
    vm.startPrank(alice);
    vm.deal(alice, 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, alice);
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    vm.stopPrank();

    // Then 1st user withdraw half of his underlying
    uint256 _shareBefore = ybeth.balanceOf(address(this));
    uint256 _burnedShare = ybeth.withdrawETH(520 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), _shareBefore - _burnedShare);
    assertEq(ybeth.totalAssets(), 2_040.1 ether - 520 ether);
    assertEq(weth.balanceOf(address(ybeth)), 2_040.1 ether - 520 ether);
    assertEq(ybeth.totalSupply(), 1_000.1 ether + _expectedAliceShares - _burnedShare);
    assertEq(address(this).balance, 520 ether);

    // The 1st user withdraw the rest.
    uint256 _maxWithdraw = ybeth.maxWithdraw(address(this));
    _burnedShare = ybeth.withdrawETH(_maxWithdraw, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 0);
    assertEq(ybeth.totalAssets(), 1_520.1 ether - _maxWithdraw);
    assertEq(weth.balanceOf(address(ybeth)), 1_520.1 ether - _maxWithdraw);
    assertEq(ybeth.totalSupply(), _expectedAliceShares + 0.1 ether);
    assertEq(address(this).balance, 520 ether + _maxWithdraw);

    // Alice withdraw all of underlying
    vm.prank(alice);
    ybeth.withdrawETH(1_000 ether, alice, alice);
    // Assert
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.totalAssets(), 103999600039996001);
    assertEq(weth.balanceOf(address(ybeth)), 103999600039996001);
    assertEq(ybeth.totalSupply(), 0.1 ether);
    assertEq(alice.balance, 1_000 ether);
  }

  receive() external payable {}
}
