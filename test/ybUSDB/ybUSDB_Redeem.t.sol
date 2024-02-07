// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {ybUSDB_BaseTest, SafeTransferLib} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSD_RedeemTest is ybUSDB_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testRevert_WhenRedeemZero() external {
    // Assuming someone deposit but won't get any share
    // due to precision loss.
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 1_000 ether);
    assertEq(ybusdb.totalAssets(), 1_000 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_000 ether);
    assertEq(ybusdb.totalSupply(), 1_000 ether);

    // Redeem zero
    vm.expectRevert(abi.encodeWithSignature("ZeroAssets()"));
    ybusdb.redeem(0, address(this), address(this));
  }

  function testCorrectness_WhenRedeemSuccessfully() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 1_000 ether);
    assertEq(ybusdb.totalAssets(), 1_000 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_000 ether);
    assertEq(ybusdb.totalSupply(), 1_000 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next redeem is called, the 1st user should received correct amount of USDB.
    mockUsdb.setNextYield(40 ether);

    // Alice deposit 1_000 weth to ybUSDB
    vm.startPrank(alice);
    // Mint 1_000 USDB
    mockUsdb.mint(alice, 1_000 ether);
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, alice);
    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    vm.stopPrank();

    // Then 1st user redeem half of his ybUSDB
    ybusdb.redeem(500 ether, address(this), address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 500 ether);
    assertEq(ybusdb.totalAssets(), 2_040 ether - 520 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 2_040 ether - 520 ether);
    assertEq(ybusdb.totalSupply(), 1_000 ether + _expectedAliceShares - 500 ether);
    assertEq(mockUsdb.balanceOf(address(this)), 520 ether);

    // The 1st user redeem the rest.
    ybusdb.redeem(500 ether, address(this), address(this));
    // Assert
    assertEq(ybusdb.balanceOf(address(this)), 0);
    assertEq(ybusdb.totalAssets(), 1_520 ether - 520 ether);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 1_520 ether - 520 ether);
    assertEq(ybusdb.totalSupply(), _expectedAliceShares);
    assertEq(mockUsdb.balanceOf(address(this)), 1_040 ether);

    // Alice redeem all of her ybUSDB
    vm.prank(alice);
    ybusdb.redeem(_expectedAliceShares, alice, alice);
    // Assert
    assertEq(ybusdb.balanceOf(alice), 0);
    assertEq(ybusdb.totalAssets(), 0);
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 0);
    assertEq(ybusdb.totalSupply(), 0);
    assertEq(mockUsdb.balanceOf(alice), 1_000 ether);
  }
}
