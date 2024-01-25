// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {Test} from "lib/forge-std/src/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

// Tests
import {MockBlast} from "test/mocks/MockBlast.sol";
import {MockWethRebasing} from "test/mocks/MockWethRebasing.sol";
import {MockWETH9} from "test/mocks/MockWETH9.sol";

// Contracts
import {ybETH} from "src/ybETH.sol";
import {IWETH} from "src/interfaces/IWETH.sol";
import {IWETHUSDBRebasing} from "src/interfaces/IWETHUSDBRebasing.sol";

abstract contract ybETH_BaseTest is Test {
  address public alice;

  MockBlast public mockBlast;
  MockWETH9 public weth;
  ybETH public ybeth;

  function setUp() public virtual {
    mockBlast = new MockBlast();
    weth = new MockWETH9();
    ybeth = new ybETH(IWETH(address(weth)), mockBlast);
    alice = makeAddr("alice");
  }
}
