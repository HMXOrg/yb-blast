// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

enum YieldMode {
  AUTOMATIC,
  VOID,
  CLAIMABLE
}

interface IWETHUSDBRebasing {
  function configure(YieldMode) external returns (uint256);

  function claimAllYield(address contractAddress, address receipientOfYield) external returns (uint256);
}
