// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybETH_BaseTest} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_DevTest is ybETH_BaseTest {
  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenSetDevByNonDev() external {
    vm.prank(alice);
    vm.expectRevert("FORBIDDEN");
    ybeth.setDev(alice);
  }

  function testRevert_WHenNonDevTrySetPointsOperator() external {
    vm.prank(alice);
    vm.expectRevert("FORBIDDEN");
    ybeth.setPointsOperator(alice);
  }

  function testCorrectness_WhenDeployed() external {
    assertEq(ybeth.dev(), address(this));
  }

  function testCorrectness_WhenSetDev() external {
    ybeth.setDev(alice);
    assertEq(ybeth.dev(), alice);
  }

  function testCorrectness_WhenSetPointsOperator() external {
    ybeth.setPointsOperator(alice);
  }
}
