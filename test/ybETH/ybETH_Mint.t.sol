// // SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest, SafeTransferLib} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_MintTest is ybETH_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testCorrectness_WhenMintSuccessfully() external {
    // Deal and mint 1_000 weth
    vm.deal(address(this), 1_000 ether);
    address(weth).safeTransferETH(1_000 ether);
    // Deposit to ybETH
    weth.approve(address(ybeth), 1_000 ether);
    ybeth.mint(1_000 ether, address(this));
    // Assert
    assertEq(ybeth.balanceOf(address(this)), 1_000 ether);
    assertEq(ybeth.totalAssets(), 1_000.1 ether);
    assertEq(weth.balanceOf(address(ybeth)), 1_000.1 ether);
    assertEq(ybeth.totalSupply(), 1_000.1 ether);

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
    uint256 _shares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    ybeth.mint(_shares, alice);
    vm.stopPrank();
    // Assert
    assertEq(ybeth.balanceOf(alice), _shares);
    assertEq(ybeth.totalAssets(), 2_040.1 ether);
    assertEq(weth.balanceOf(address(ybeth)), 2_040.1 ether);
    assertEq(ybeth.totalSupply(), 1_000.1 ether + _shares);
  }
}
