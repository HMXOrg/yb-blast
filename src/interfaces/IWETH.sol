// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

abstract contract IWETH is ERC20 {
  function deposit() external payable virtual;
  function withdraw(uint256 _amount) external virtual;
}
