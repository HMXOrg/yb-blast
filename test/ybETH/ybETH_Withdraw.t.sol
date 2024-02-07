// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_WithdrawTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenWithdrawSuccessfully() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next redeem is called, the 1st user should received correct amount of WETH.
    weth.setNextYield(40 ether);

    // Alice deposit 1_000 weth to ybETH
    vm.startPrank(alice);
    vm.deal(alice, 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, alice);
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    vm.stopPrank();

    // Then 1st user withdraw half of his underlying
    ybeth.withdraw(520 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 500 ether);
    assertEq(ybeth.totalAssets(), 2_040 ether - 520 ether);
    assertEq(weth.balanceOf(address(ybeth)), 2_040 ether - 520 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether + _expectedAliceShares - 500 ether);
    assertEq(weth.balanceOf(address(this)), 520 ether);

    // The 1st user withdraw the rest.
    ybeth.withdraw(520 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 0);
    assertEq(ybeth.totalAssets(), 1_520 ether - 520 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_520 ether - 520 ether);
    assertEq(ybeth.totalSupply(), _expectedAliceShares);
    assertEq(weth.balanceOf(address(this)), 1_040 ether);

    // Alice withdraw all of underlying
    vm.prank(alice);
    ybeth.withdraw(1_000 ether, alice, alice);
    // Assert
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.totalAssets(), 0);
    assertEq(weth.balanceOf(address(ybeth)), 0);
    assertEq(ybeth.totalSupply(), 0);
    assertEq(weth.balanceOf(alice), 1_000 ether);
  }
}
