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
import {ybETH} from "src/ybETH.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

abstract contract ybETH_BaseTest is Test {
  address public alice;

  MockErc20Rebasing public weth;
  ybETH public ybeth;

  function setUp() public virtual {
    alice = makeAddr("alice");

    weth = new MockErc20Rebasing();
    ybeth = new ybETH(weth);
  }
}
