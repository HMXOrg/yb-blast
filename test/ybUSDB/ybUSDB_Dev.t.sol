// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybUSDB_BaseTest} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSDB_DevTest is ybUSDB_BaseTest {
  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenSetDevByNonDev() external {
    vm.prank(alice);
    vm.expectRevert("FORBIDDEN");
    ybusdb.setDev(alice);
  }

  function testRevert_WHenNonDevTrySetPointsOperator() external {
    vm.prank(alice);
    vm.expectRevert("FORBIDDEN");
    ybusdb.setPointsOperator(alice);
  }

  function testCorrectness_WhenDeployed() external {
    assertEq(ybusdb.dev(), address(this));
  }

  function testCorrectness_WhenSetDev() external {
    ybusdb.setDev(alice);
    assertEq(ybusdb.dev(), alice);
  }

  function testCorrectness_WhenSetPointsOperator() external {
    ybusdb.setPointsOperator(alice);
  }
}
