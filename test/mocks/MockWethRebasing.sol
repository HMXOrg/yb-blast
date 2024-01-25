// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

import {IWETHUSDBRebasing, YieldMode} from "src/interfaces/IWETHUSDBRebasing.sol";

/// @title MockWethRebasing - Mock contract for WETH rebasing contract. Testing only.
/// @dev On Blast, MockWethRebasing is also WETH.
contract MockWethRebasing is IWETHUSDBRebasing, ERC20 {
  using SafeTransferLib for ERC20;

  YieldMode public yieldMode;
  uint256 public nextYield;

  constructor() ERC20("WETH", "WETH", 18) {}

  function configure(YieldMode _yieldMode) external override returns (uint256) {
    yieldMode = _yieldMode;
    return 1;
  }

  function feedNextYield(uint256 _yield) external {
    nextYield = _yield;
  }

  function claimAllYield(address, address _to) external override returns (uint256) {
    uint256 _yield = nextYield;
    nextYield = 0;
    _mint(_to, _yield);
    return _yield;
  }

  /// @notice WETH compatible deposit function.
  function deposit() external payable {
    _mint(msg.sender, msg.value);
  }

  /// @notice WETH compatible deposit via fallback function.
  receive() external payable {
    _mint(msg.sender, msg.value);
  }
}
