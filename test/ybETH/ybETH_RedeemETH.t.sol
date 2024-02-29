// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_RedeemETHTest is ybETH_BaseTest {
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
    assertEq(ybeth.totalAssets(), 1_000.1 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000.1 ether);
    assertEq(ybeth.totalSupply(), 1_000.1 ether);

    // Redeem zero
    vm.expectRevert(abi.encodeWithSignature("ZeroAssets()"));
    ybeth.redeemETH(0, address(this), address(this));
  }

  function testCorrectness_WhenRedeemETHSuccessfully() external {
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

    // Then 1st user redeem half of his ybETH
    uint256 _receivedETH = ybeth.redeemETH(500 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 500 ether);
    assertEq(ybeth.totalAssets(), 2_040.1 ether - _receivedETH);
    assertEq(weth.balanceOf(address(ybeth)), 2_040.1 ether - _receivedETH);
    assertEq(ybeth.totalSupply(), 1_000.1 ether + _expectedAliceShares - 500 ether);
    assertEq(address(this).balance, _receivedETH);

    // The 1st user redeem the rest.
    _receivedETH = ybeth.redeemETH(500 ether, address(this), address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 0);
    assertApproxEqAbs(ybeth.totalAssets(), 2_040.1 ether - _receivedETH * 2, 1);
    assertApproxEqAbs(weth.balanceOf(address(ybeth)), 2_040.1 ether - _receivedETH * 2, 1);
    assertEq(ybeth.totalSupply(), _expectedAliceShares + 0.1 ether);
    assertApproxEqAbs(address(this).balance, _receivedETH * 2, 1);

    // Alice redeem all of her ybETH
    vm.prank(alice);
    _receivedETH = ybeth.redeemETH(_expectedAliceShares, alice, alice);
    // Assert
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.totalAssets(), 103999600039996001);
    assertEq(weth.balanceOf(address(ybeth)), 103999600039996001);
    assertEq(ybeth.totalSupply(), 0.1 ether);
    assertEq(alice.balance, _receivedETH);
  }

  receive() external payable {}
}
