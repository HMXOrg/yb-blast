// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CommonBase} from "lib/forge-std/src/Base.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

import {IBlast, GasMode, YieldMode} from "src/interfaces/IBlast.sol";

/// @title MockBlast - Mock contract for Blast system contract. Testing only.
contract MockBlast is CommonBase, IBlast {
  using SafeTransferLib for address;

  YieldMode public yieldMode;
  uint256 public nextYield;

  function configureClaimableYield() external override {}

  function setNextYield(uint256 _yield) external {
    nextYield = _yield;
  }

  function readClaimableYield(address) external view override returns (uint256) {
    return nextYield;
  }

  function claimAllYield(address, address _to) external override returns (uint256) {
    uint256 _yield = nextYield;
    nextYield = 0;
    vm.deal(_to, _to.balance + _yield);
    return _yield;
  }

  function configureClaimableGas() external override {}

  function configureGovernor(address) external override {}

  function claimAllGas(address, address) external pure override returns (uint256) {
    return 0;
  }

  function readGasParams(address)
    external
    pure
    override
    returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode)
  {
    return (0, 0, 0, GasMode.VOID);
  }
}
