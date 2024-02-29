// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybUSDB_BaseTest, SafeTransferLib} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSDB_WithdrawTest is ybUSDB_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenWithdrawSuccessfully() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 1_000 ether);
    assertEq(ybusdb.totalAssets(), 1_000.1 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_000.1 ether);
    assertEq(ybusdb.totalSupply(), 1_000.1 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next redeem is called, the 1st user should received correct amount of USDB.
    mockUsdb.setNextYield(40 ether);

    // Alice deposit 1_000 mockUsdb to ybUSDB
    vm.startPrank(alice);
    // Mint 1_000 USDB to alice
    mockUsdb.mint(alice, 1_000 ether);
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, alice);
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    vm.stopPrank();

    // Then 1st user withdraw half of his underlying
    uint256 _shareBefore = ybusdb.balanceOf(address(this));
    uint256 _burnedShare = ybusdb.withdraw(520 ether, address(this), address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), _shareBefore - _burnedShare);
    assertEq(ybusdb.totalAssets(), 2_040.1 ether - 520 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 2_040.1 ether - 520 ether);
    assertEq(ybusdb.totalSupply(), 1_000.1 ether + _expectedAliceShares - _burnedShare);
    assertEq(mockUsdb.balanceOf(address(this)), 520 ether);

    // The 1st user withdraw the rest.
    uint256 _maxWithdraw = ybusdb.maxWithdraw(address(this));
    _burnedShare = ybusdb.withdraw(_maxWithdraw, address(this), address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 0);
    assertEq(ybusdb.totalAssets(), 1_520.1 ether - _maxWithdraw);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_520.1 ether - _maxWithdraw);
    assertEq(ybusdb.totalSupply(), _expectedAliceShares + 0.1 ether);
    assertEq(mockUsdb.balanceOf(address(this)), 520 ether + _maxWithdraw);

    // Alice withdraw all of underlying
    vm.prank(alice);
    ybusdb.withdraw(1_000 ether, alice, alice);
    // Assert
    assertEq(ybusdb.balanceOf(alice), 0);
    assertEq(ybusdb.totalAssets(), 103999600039996001);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 103999600039996001);
    assertEq(ybusdb.totalSupply(), 0.1 ether);
    assertEq(mockUsdb.balanceOf(alice), 1_000 ether);
  }
}
