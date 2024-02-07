// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ybETH_BaseTest} from "test/ybETH/ybETH_Base.t.sol";

contract ybETH_RoundingTest is ybETH_BaseTest {
  function testCorrectness_Rounding() public {
    uint256 mutationUnderlyingAmount = 3000;

    weth.mint(alice, 4000);

    vm.prank(alice);
    weth.approve(address(ybeth), 4000);

    assertEq(weth.allowance(alice, address(ybeth)), 4000);

    weth.mint(bob, 7001);

    vm.prank(bob);
    weth.approve(address(ybeth), 7001);

    assertEq(weth.allowance(bob, address(ybeth)), 7001);

    // 1. Alice mints 2000 shares (costs 2000 tokens)
    vm.prank(alice);
    uint256 aliceUnderlyingAmount = ybeth.mint(2000, alice);

    uint256 aliceShareAmount = ybeth.previewDeposit(aliceUnderlyingAmount);

    // Expect to have received the requested mint amount.
    assertEq(aliceShareAmount, 2000);
    assertEq(ybeth.balanceOf(alice), aliceShareAmount);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), aliceUnderlyingAmount);
    assertEq(ybeth.convertToShares(aliceUnderlyingAmount), ybeth.balanceOf(alice));

    // Expect a 1:1 ratio before mutation.
    assertEq(aliceUnderlyingAmount, 2000);

    // Sanity check.
    assertEq(ybeth.totalSupply(), aliceShareAmount);
    assertEq(ybeth.totalAssets(), aliceUnderlyingAmount);

    // 2. Bob deposits 4000 tokens (mints 4000 shares)
    vm.prank(bob);
    uint256 bobShareAmount = ybeth.deposit(4000, bob);
    uint256 bobUnderlyingAmount = ybeth.previewWithdraw(bobShareAmount);

    // Expect to have received the requested underlying amount.
    assertEq(bobUnderlyingAmount, 4000);
    assertEq(ybeth.balanceOf(bob), bobShareAmount);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), bobUnderlyingAmount);
    assertEq(ybeth.convertToShares(bobUnderlyingAmount), ybeth.balanceOf(bob));

    // Expect a 1:1 ratio before mutation.
    assertEq(bobShareAmount, bobUnderlyingAmount);

    // Sanity check.
    uint256 preMutationShareBal = aliceShareAmount + bobShareAmount;
    uint256 preMutationBal = aliceUnderlyingAmount + bobUnderlyingAmount;
    assertEq(ybeth.totalSupply(), preMutationShareBal);
    assertEq(ybeth.totalAssets(), preMutationBal);
    assertEq(ybeth.totalSupply(), 6000);
    assertEq(ybeth.totalAssets(), 6000);

    // 3. Vault mutates by +3000 tokens...                    |
    //    (simulated yield returned from strategy)...
    // The Vault now contains more tokens than deposited which causes the exchange rate to change.
    // Alice share is 33.33% of the Vault, Bob 66.66% of the ybeth.
    // Alice's share count stays the same but the underlying amount changes from 2000 to 3000.
    // Bob's share count stays the same but the underlying amount changes from 4000 to 6000.
    weth.setNextYield(mutationUnderlyingAmount);
    assertEq(ybeth.totalSupply(), preMutationShareBal);
    assertEq(ybeth.totalAssets(), preMutationBal + mutationUnderlyingAmount);
    assertEq(ybeth.balanceOf(alice), aliceShareAmount);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), aliceUnderlyingAmount + (mutationUnderlyingAmount / 3) * 1);
    assertEq(ybeth.balanceOf(bob), bobShareAmount);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), bobUnderlyingAmount + (mutationUnderlyingAmount / 3) * 2);

    // 4. Alice deposits 2000 tokens (mints 1333 shares)
    vm.prank(alice);
    ybeth.deposit(2000, alice);

    assertEq(ybeth.totalSupply(), 7333);
    assertEq(ybeth.balanceOf(alice), 3333);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 4999);
    assertEq(ybeth.balanceOf(bob), 4000);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 6000);

    // 5. Bob mints 2000 shares (costs 3001 assets)
    // NOTE: Bob's assets spent got rounded up
    // NOTE: Alices's vault assets got rounded up
    vm.prank(bob);
    ybeth.mint(2000, bob);

    assertEq(ybeth.totalSupply(), 9333);
    assertEq(ybeth.balanceOf(alice), 3333);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 5000);
    assertEq(ybeth.balanceOf(bob), 6000);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 9000);

    // Sanity checks:
    // Alice and bob should have spent all their tokens now
    assertEq(weth.balanceOf(alice), 0);
    assertEq(weth.balanceOf(bob), 0);
    // Assets in vault: 4k (alice) + 7k (bob) + 3k (yield) + 1 (round up)
    assertEq(ybeth.totalAssets(), 14001);

    // 6. Vault mutates by +3000 tokens
    // NOTE: Vault holds 17001 tokens, but sum of assetsOf() is 17000.
    weth.setNextYield(mutationUnderlyingAmount);
    assertEq(ybeth.totalAssets(), 17001);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 6071);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 10929);

    // 7. Alice redeem 1333 shares (2428 assets)
    vm.prank(alice);
    ybeth.redeem(1333, alice, alice);

    assertEq(weth.balanceOf(alice), 2428);
    assertEq(ybeth.totalSupply(), 8000);
    assertEq(ybeth.totalAssets(), 14573);
    assertEq(ybeth.balanceOf(alice), 2000);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 3643);
    assertEq(ybeth.balanceOf(bob), 6000);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 10929);

    // 8. Bob withdraws 2929 assets (1608 shares)
    vm.prank(bob);
    ybeth.withdraw(2929, bob, bob);

    assertEq(weth.balanceOf(bob), 2929);
    assertEq(ybeth.totalSupply(), 6392);
    assertEq(ybeth.totalAssets(), 11644);
    assertEq(ybeth.balanceOf(alice), 2000);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 3643);
    assertEq(ybeth.balanceOf(bob), 4392);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 8000);

    // 9. Alice withdraws 3643 assets (2000 shares)
    // NOTE: Bob's assets have been rounded back up
    vm.prank(alice);
    ybeth.withdraw(3643, alice, alice);

    assertEq(weth.balanceOf(alice), 6071);
    assertEq(ybeth.totalSupply(), 4392);
    assertEq(ybeth.totalAssets(), 8001);
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 0);
    assertEq(ybeth.balanceOf(bob), 4392);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 8001);

    // 10. Bob redeem 4392 shares (8001 tokens)
    vm.prank(bob);
    ybeth.redeem(4392, bob, bob);
    assertEq(weth.balanceOf(bob), 10930);
    assertEq(ybeth.totalSupply(), 0);
    assertEq(ybeth.totalAssets(), 0);
    assertEq(ybeth.balanceOf(alice), 0);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(alice)), 0);
    assertEq(ybeth.balanceOf(bob), 0);
    assertEq(ybeth.convertToAssets(ybeth.balanceOf(bob)), 0);

    // Sanity check
    assertEq(weth.balanceOf(address(ybeth)), 0);
  }
}
