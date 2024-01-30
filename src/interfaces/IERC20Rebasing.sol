// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

enum YieldMode {
  AUTOMATIC,
  VOID,
  CLAIMABLE
}

abstract contract IERC20Rebasing is ERC20 {
  function configure(YieldMode) external virtual returns (uint256);
  function claim(address recipient, uint256 amount) external virtual returns (uint256);
  function getClaimableAmount(address account) external view virtual returns (uint256);
}
