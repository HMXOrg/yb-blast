// // SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybUSDB_BaseTest, SafeTransferLib} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSDB_MintTest is ybUSDB_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testCorrectness_WhenMintSuccessfully() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.mint(1_000 ether, address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 1_000 ether);
    assertEq(ybusdb.totalAssets(), 1_000 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_000 ether);
    assertEq(ybusdb.totalSupply(), 1_000 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    // Next user deposit to ybUSDB
    vm.startPrank(alice);
    // Deal and mint 1_000 USDB
    mockUsdb.mint(alice, 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    uint256 _shares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    ybusdb.mint(_shares, alice);
    vm.stopPrank();
    // Assert
    assertEq(ybusdb.balanceOf(alice), _shares);
    assertEq(ybusdb.totalAssets(), 2_040 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 2_040 ether);
    assertEq(ybusdb.totalSupply(), 1_000 ether + _shares);
  }
}
