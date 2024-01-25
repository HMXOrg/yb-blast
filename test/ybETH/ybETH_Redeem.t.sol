// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_RedeemTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenRedeemZero() external {
    // Assuming someone deposit but won't get any share
    // due to precision loss.
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000 ether);
    assertEq(address(ybeth).balance, 1_000 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether);

    // Redeem zero
    vm.expectRevert(abi.encodeWithSignature("ZeroAssets()"));
    ybeth.redeem(0, address(this), address(this));
  }

  function testCorrectness_WhenRedeemSuccessfully() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000 ether);
    assertEq(address(ybeth).balance, 1_000 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether);

    // Assuming WETH is rebased, totalAssets should be updated
    // when the next redeem is called, the 1st user should received correct amount of WETH.
    mockBlast.setNextYield(40 ether);

    // Alice deposit 1_000 weth to ybETH
    vm.startPrank(alice);
    vm.deal(alice, 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.deposit(1_000 ether, alice);
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    vm.stopPrank();

    // Then 1st user redeem half of his ybETH
    ybeth.redeem(500 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 500 ether);
    assertEq(ybeth.totalAssets(), 2_040 ether - 520 ether);
    assertEq(address(ybeth).balance, 2_040 ether - 520 ether);
    assertEq(ybeth.totalSupply(), 1_000 ether + _expectedAliceShares - 500 ether);
    assertEq(weth.balanceOf(address(this)), 520 ether);

    // The 1st user redeem the rest.
    ybeth.redeem(500 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 0);
    assertEq(ybeth.totalAssets(), 1_520 ether - 520 ether);
    assertEq(address(ybeth).balance, 1_520 ether - 520 ether);
    assertEq(ybeth.totalSupply(), _expectedAliceShares);
    assertEq(weth.balanceOf(address(this)), 1_040 ether);

    // Alice redeem all of her ybETH
    vm.prank(alice);
    ybeth.redeem(_expectedAliceShares, alice, alice);
    // Assert
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.totalAssets(), 0);
    assertEq(address(ybeth).balance, 0);
    assertEq(ybeth.totalSupply(), 0);
    assertEq(weth.balanceOf(alice), 1_000 ether);
  }
}
