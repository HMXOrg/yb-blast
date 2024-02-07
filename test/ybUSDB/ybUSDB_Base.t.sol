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
import {ybUSDB} from "src/ybUSDB.sol";
import {IERC20Rebasing} from "src/interfaces/IERC20Rebasing.sol";

abstract contract ybUSDB_BaseTest is Test {
  address public alice;
  address public bob;

  MockErc20Rebasing public mockUsdb;
  ybUSDB public ybusdb;

  function setUp() public virtual {
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    mockUsdb = new MockErc20Rebasing();
    ybusdb = new ybUSDB(mockUsdb);
  }
}
