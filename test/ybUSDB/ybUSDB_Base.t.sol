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
import {MockBlastPoints} from "test/mocks/MockBlastPoints.sol";

// Contracts
import {ybUSDB} from "src/ybUSDB.sol";
import {IERC20Rebasing} from "src/interfaces/IERC20Rebasing.sol";

abstract contract ybUSDB_BaseTest is Test {
  address public alice;
  address public bob;

  MockBlast public blast;
  MockBlastPoints public blastPoints;
  MockErc20Rebasing public mockUsdb;

  ybUSDB public ybusdb;

  function setUp() public virtual {
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    blast = new MockBlast();
    blastPoints = new MockBlastPoints();
    mockUsdb = new MockErc20Rebasing();

    // Mint 0.1 USDB to deployer to seed the vault
    mockUsdb.mint(address(this), 0.1 ether);
    mockUsdb.approve(0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9, 0.1 ether);

    ybusdb = new ybUSDB(mockUsdb, blast, blastPoints, address(this));
  }
}
