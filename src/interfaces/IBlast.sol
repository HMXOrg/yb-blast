// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

enum YieldMode {
  AUTOMATIC,
  VOID,
  CLAIMABLE
}

enum GasMode {
  VOID,
  CLAIMABLE
}

interface IBlast {
  function configureClaimableYield() external;
  function claimAllYield(address contractAddress, address receipientOfYield) external returns (uint256);
  function readClaimableYield(address contractAddress) external view returns (uint256);
  function configureClaimableGas() external;
  function claimAllGas(address contractAddress, address receipientOfGas) external returns (uint256);
  function readGasParams(address contractAddress)
    external
    view
    returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode);
}
