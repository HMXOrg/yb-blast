// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Test} from "lib/forge-std/src/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

// Tests
import {MockErc20Rebasing} from "test/mocks/MockErc20Rebasing.sol";

// Contracts
import {YieldInbox} from "src/YieldInbox.sol";

contract YieldInbox_Test is Test {
  address public alice;
  address public bob;

  MockErc20Rebasing public weth;
  YieldInbox public yieldInbox;

  function setUp() public virtual {
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    weth = new MockErc20Rebasing();
    yieldInbox = new YieldInbox();
  }

  function testRevert_WhenNotControllerCrawlBack() external {
    vm.expectRevert("!auth");
    vm.prank(alice);
    yieldInbox.crawlBack(weth, address(this), 1_000 ether);
  }

  function testCorrectness_WhenControllerCrawlBack() external {
    // Setup 1_000 WETH in YieldInbox
    vm.deal(address(this), 1_000 ether);
    weth.deposit{value: 1_000 ether}();
    weth.transfer(address(yieldInbox), 1_000 ether);

    // Crawl back 1_000 WETH
    yieldInbox.crawlBack(weth, address(this), 1_000 ether);

    // Should have 1_000 WETH
    assertEq(weth.balanceOf(address(this)), 1_000 ether);
  }
}
