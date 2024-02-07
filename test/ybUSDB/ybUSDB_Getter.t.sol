// // SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Test
import {console2} from "lib/forge-std/src/console2.sol";
import {ybUSDB_BaseTest, SafeTransferLib} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSDB_GetterTest is ybUSDB_BaseTest {
  using SafeTransferLib for address;

  function setUp() public override {
    super.setUp();
  }

  function testCorrectness_Asset() external {
    assertEq(address(ybusdb.asset()), address(mockUsdb));
  }

  function testCorrectness_MaxDeposit() external {
    assertEq(ybusdb.maxDeposit(address(this)), type(uint256).max);
  }

  function testCorrectness_MaxMint() external {
    assertEq(ybusdb.maxMint(address(this)), type(uint256).max);
  }

  function testCorrectness_MaxWithdraw() external {
    assertEq(ybusdb.maxWithdraw(address(this)), 0);

    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    assertEq(ybusdb.maxWithdraw(address(this)), 1_000 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    // Without any interaction to the contract, it should returns correct value.
    assertEq(ybusdb.maxWithdraw(address(this)), 1_040 ether);

    // Next user deposit to ybUSDB
    vm.startPrank(alice);
    // Deal and mint 1_000 weth
    mockUsdb.mint(alice, 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, alice);
    vm.stopPrank();

    assertEq(ybusdb.maxWithdraw(address(this)), 1_040 ether);
    assertApproxEqAbs(ybusdb.maxWithdraw(alice), 1_000 ether, 1);
  }

  function testCorrectness_MaxWithdraw_WhenUnclaimedYield() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    assertEq(ybusdb.maxWithdraw(address(this)), 1_000 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    assertEq(ybusdb.maxWithdraw(address(this)), 1_040 ether);
  }

  function testCorrectness_MaxRedeem() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    assertEq(ybusdb.maxRedeem(address(this)), 1_000 ether);

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    // Next user deposit to ybUSDB
    vm.startPrank(alice);
    // Mint 1_000 USDB for Alice
    mockUsdb.mint(alice, 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, alice);
    vm.stopPrank();

    uint256 _expectedAliceShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    assertEq(ybusdb.maxRedeem(address(this)), 1_000 ether);
    assertEq(ybusdb.maxRedeem(alice), _expectedAliceShares);
  }

  function testCorrectness_PreviewDeposit_WhenUnclaimedYield() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    uint256 _expectedShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    assertEq(ybusdb.previewDeposit(1_000 ether), _expectedShares);
  }

  function testCorrectness_PreviewRedeem_WhenUnclaimedYield() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    assertEq(ybusdb.previewRedeem(1_000 ether), 1_040 ether);
  }

  function testCorrectness_PreviewMint_WhenUnclaimedYield() external {
    // Mint 1_000 USDB
    mockUsdb.mint(address(this), 1_000 ether);
    // Deposit to ybUSDB
    mockUsdb.approve(address(ybusdb), 1_000 ether);
    ybusdb.deposit(1_000 ether, address(this));

    // Assuming USDB is rebased, totalAssets should be updated
    // when the next deposit is called, hence the next user should
    // receive less shares.
    mockUsdb.setNextYield(40 ether);

    uint256 _expectedShares = uint256(1_000 ether) * uint256(1_000 ether) / uint256(1_040 ether);
    assertEq(ybusdb.previewMint(_expectedShares), 1_000 ether);
  }
}
