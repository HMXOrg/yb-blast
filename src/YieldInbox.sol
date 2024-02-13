// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

contract YieldInbox {
  using SafeTransferLib for ERC20;

  // Config
  address public immutable controller;

  constructor() {
    controller = msg.sender;
  }

  function crawlBack(ERC20 _token, address _to, uint256 _amount) external {
    require(msg.sender == controller, "!auth");
    _token.safeTransfer(_to, _amount);
  }
}
