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
import {ybETH} from "src/ybETH.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

abstract contract ybETH_BaseTest is Test {
  address public alice;
  address public bob;

  MockBlast public blast;
  MockBlastPoints public blastPoints;
  MockErc20Rebasing public weth;
  ybETH public ybeth;

  function setUp() public virtual {
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    weth = new MockErc20Rebasing();
    blast = new MockBlast();
    blastPoints = new MockBlastPoints();

    // Mint 0.1 WETH to deployer to seed the vault
    vm.deal(address(this), 0.1 ether);
    weth.deposit{value: 0.1 ether}();
    weth.approve(0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9, 0.1 ether);
    ybeth = new ybETH(weth, blast, blastPoints, address(this));
  }
}
