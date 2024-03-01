// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Test} from "lib/forge-std/src/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

// Tests
import {MockErc20Rebasing} from "test/mocks/MockErc20Rebasing.sol";
import {MockBlast} from "test/mocks/MockBlast.sol";

// Contracts
import {ybETH} from "src/ybETH.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

abstract contract ybETH_BaseTest is Test {
  address public alice;
  address public bob;

  MockBlast public blast;
  MockErc20Rebasing public weth;
  ybETH public ybeth;

  function setUp() public virtual {
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    weth = new MockErc20Rebasing();
    blast = new MockBlast();

    // Mint 0.1 WETH to deployer to seed the vault
    vm.deal(address(this), 0.1 ether);
    weth.deposit{value: 0.1 ether}();
    weth.approve(0xF62849F9A0B5Bf2913b396098F7c7019b51A820a, 0.1 ether);
    ybeth = new ybETH(weth, blast);
  }
}
