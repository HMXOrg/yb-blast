// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

import {IERC20Rebasing} from "src/interfaces/IERC20Rebasing.sol";
import {IBlast} from "src/interfaces/IBlast.sol";
import {ybETH} from "src/ybETH.sol";

contract ybETH_Deployer is Script {
  function run() external {
    uint256 key = vm.envUint("MAINNET_PRIVATE_KEY");
    IERC20Rebasing weth = IERC20Rebasing(0x4300000000000000000000000000000000000004);
    IBlast blast = IBlast(0x4300000000000000000000000000000000000002);

    vm.startBroadcast(key);

    weth.approve(0x2EAd9c6C7cAB1DD3442714A8A8533078C402135A, type(uint256).max);
    new ybETH(weth, blast);

    vm.stopBroadcast();
  }
}
