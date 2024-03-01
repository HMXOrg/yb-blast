// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybUSDB_BaseTest, SafeTransferLib} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybusdb_DepositTest is ybUSDB_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenPrecisionLoss() external {
    // Assuming someone deposit but won't get any share
    // due to precision loss.
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

    // Assuming we have a large pending yields
    // which then inflated the share value.
    mockUsdb.setNextYield(120_000_000 ether);
    ybusdb.claimAllYield();

    // Now share value of ybusdb is extremely expensive.
    // 1 ybusdb = 120_001_000 / 1_000 = 120_001 usdb
    // Next user deposit small USDB to ybusdb
    vm.startPrank(alice);
    // Mint 1 wei of usdb
    mockUsdb.mint(address(this), 1 wei);
    // Deposit to ybusdb
    mockUsdb.approve(address(ybusdb), 1 wei);
    vm.expectRevert(abi.encodeWithSignature("ZeroShares()"));
    ybusdb.deposit(1 wei, alice);
    vm.stopPrank();
  }

  function testCorrectness_WhenDepositSuccessfully() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybusdb
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 1_000 ether);
    assertEq(ybusdb.totalAssets(), 1_000.1 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_000.1 ether);
    assertEq(ybusdb.totalSupply(), 1_000.1 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    // Next user deposit to ybusdb
    vm.startPrank(alice);
    // Deal and mint 1_000 usdb
    mockUsdb.mint(alice, 1_000 ether);
    // Deposit to ybusdb
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, alice);
    vm.stopPrank();
    // Assert
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000.1 ether) / uint256(1_040.1 ether);
    assertEq(ybusdb.balanceOf(alice), _expectedAliceShares);
    assertEq(ybusdb.totalAssets(), 2_040.1 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 2_040.1 ether);
    assertEq(ybusdb.totalSupply(), 1_000.1 ether + _expectedAliceShares);
  }
}
