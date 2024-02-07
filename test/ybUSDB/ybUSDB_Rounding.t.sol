// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ybUSDB_BaseTest} from "test/ybUSDB/ybUSDB_Base.t.sol";

contract ybUSDB_RoundingTest is ybUSDB_BaseTest {
  function testCorrectness_Rounding() public {
    uint256 mutationUnderlyingAmount = 3000;

    mockUsdb.mint(alice, 4000);

    vm.prank(alice);
    mockUsdb.approve(address(ybusdb), 4000);

    assertEq(mockUsdb.allowance(alice, address(ybusdb)), 4000);

    mockUsdb.mint(bob, 7001);

    vm.prank(bob);
    mockUsdb.approve(address(ybusdb), 7001);

    assertEq(mockUsdb.allowance(bob, address(ybusdb)), 7001);

    // 1. Alice mints 2000 shares (costs 2000 tokens)
    vm.prank(alice);
    uint256 aliceUnderlyingAmount = ybusdb.mint(2000, alice);

    uint256 aliceShareAmount = ybusdb.previewDeposit(aliceUnderlyingAmount);

    // Expect to have received the requested mint amount.
    assertEq(aliceShareAmount, 2000);
    assertEq(ybusdb.balanceOf(alice), aliceShareAmount);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), aliceUnderlyingAmount);
    assertEq(ybusdb.convertToShares(aliceUnderlyingAmount), ybusdb.balanceOf(alice));

    // Expect a 1:1 ratio before mutation.
    assertEq(aliceUnderlyingAmount, 2000);

    // Sanity check.
    assertEq(ybusdb.totalSupply(), aliceShareAmount);
    assertEq(ybusdb.totalAssets(), aliceUnderlyingAmount);

    // 2. Bob deposits 4000 tokens (mints 4000 shares)
    vm.prank(bob);
    uint256 bobShareAmount = ybusdb.deposit(4000, bob);
    uint256 bobUnderlyingAmount = ybusdb.previewWithdraw(bobShareAmount);

    // Expect to have received the requested underlying amount.
    assertEq(bobUnderlyingAmount, 4000);
    assertEq(ybusdb.balanceOf(bob), bobShareAmount);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), bobUnderlyingAmount);
    assertEq(ybusdb.convertToShares(bobUnderlyingAmount), ybusdb.balanceOf(bob));

    // Expect a 1:1 ratio before mutation.
    assertEq(bobShareAmount, bobUnderlyingAmount);

    // Sanity check.
    uint256 preMutationShareBal = aliceShareAmount + bobShareAmount;
    uint256 preMutationBal = aliceUnderlyingAmount + bobUnderlyingAmount;
    assertEq(ybusdb.totalSupply(), preMutationShareBal);
    assertEq(ybusdb.totalAssets(), preMutationBal);
    assertEq(ybusdb.totalSupply(), 6000);
    assertEq(ybusdb.totalAssets(), 6000);

    // 3. Vault mutates by +3000 tokens...                    |
    //    (simulated yield returned from strategy)...
    // The Vault now contains more tokens than deposited which causes the exchange rate to change.
    // Alice share is 33.33% of the Vault, Bob 66.66% of the ybusdb.
    // Alice's share count stays the same but the underlying amount changes from 2000 to 3000.
    // Bob's share count stays the same but the underlying amount changes from 4000 to 6000.
    mockUsdb.setNextYield(mutationUnderlyingAmount);
    assertEq(ybusdb.totalSupply(), preMutationShareBal);
    assertEq(ybusdb.totalAssets(), preMutationBal + mutationUnderlyingAmount);
    assertEq(ybusdb.balanceOf(alice), aliceShareAmount);
    assertEq(
      ybusdb.convertToAssets(ybusdb.balanceOf(alice)), aliceUnderlyingAmount + (mutationUnderlyingAmount / 3) * 1
    );
    assertEq(ybusdb.balanceOf(bob), bobShareAmount);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), bobUnderlyingAmount + (mutationUnderlyingAmount / 3) * 2);

    // 4. Alice deposits 2000 tokens (mints 1333 shares)
    vm.prank(alice);
    ybusdb.deposit(2000, alice);

    assertEq(ybusdb.totalSupply(), 7333);
    assertEq(ybusdb.balanceOf(alice), 3333);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 4999);
    assertEq(ybusdb.balanceOf(bob), 4000);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 6000);

    // 5. Bob mints 2000 shares (costs 3001 assets)
    // NOTE: Bob's assets spent got rounded up
    // NOTE: Alices's vault assets got rounded up
    vm.prank(bob);
    ybusdb.mint(2000, bob);

    assertEq(ybusdb.totalSupply(), 9333);
    assertEq(ybusdb.balanceOf(alice), 3333);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 5000);
    assertEq(ybusdb.balanceOf(bob), 6000);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 9000);

    // Sanity checks:
    // Alice and bob should have spent all their tokens now
    assertEq(mockUsdb.balanceOf(alice), 0);
    assertEq(mockUsdb.balanceOf(bob), 0);
    // Assets in vault: 4k (alice) + 7k (bob) + 3k (yield) + 1 (round up)
    assertEq(ybusdb.totalAssets(), 14001);

    // 6. Vault mutates by +3000 tokens
    // NOTE: Vault holds 17001 tokens, but sum of assetsOf() is 17000.
    mockUsdb.setNextYield(mutationUnderlyingAmount);
    assertEq(ybusdb.totalAssets(), 17001);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 6071);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 10929);

    // 7. Alice redeem 1333 shares (2428 assets)
    vm.prank(alice);
    ybusdb.redeem(1333, alice, alice);

    assertEq(mockUsdb.balanceOf(alice), 2428);
    assertEq(ybusdb.totalSupply(), 8000);
    assertEq(ybusdb.totalAssets(), 14573);
    assertEq(ybusdb.balanceOf(alice), 2000);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 3643);
    assertEq(ybusdb.balanceOf(bob), 6000);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 10929);

    // 8. Bob withdraws 2929 assets (1608 shares)
    vm.prank(bob);
    ybusdb.withdraw(2929, bob, bob);

    assertEq(mockUsdb.balanceOf(bob), 2929);
    assertEq(ybusdb.totalSupply(), 6392);
    assertEq(ybusdb.totalAssets(), 11644);
    assertEq(ybusdb.balanceOf(alice), 2000);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 3643);
    assertEq(ybusdb.balanceOf(bob), 4392);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 8000);

    // 9. Alice withdraws 3643 assets (2000 shares)
    // NOTE: Bob's assets have been rounded back up
    vm.prank(alice);
    ybusdb.withdraw(3643, alice, alice);

    assertEq(mockUsdb.balanceOf(alice), 6071);
    assertEq(ybusdb.totalSupply(), 4392);
    assertEq(ybusdb.totalAssets(), 8001);
    assertEq(ybusdb.balanceOf(alice), 0);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 0);
    assertEq(ybusdb.balanceOf(bob), 4392);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 8001);

    // 10. Bob redeem 4392 shares (8001 tokens)
    vm.prank(bob);
    ybusdb.redeem(4392, bob, bob);
    assertEq(mockUsdb.balanceOf(bob), 10930);
    assertEq(ybusdb.totalSupply(), 0);
    assertEq(ybusdb.totalAssets(), 0);
    assertEq(ybusdb.balanceOf(alice), 0);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(alice)), 0);
    assertEq(ybusdb.balanceOf(bob), 0);
    assertEq(ybusdb.convertToAssets(ybusdb.balanceOf(bob)), 0);

    // Sanity check
    assertEq(mockUsdb.balanceOf(address(ybusdb)), 0);
  }
}
