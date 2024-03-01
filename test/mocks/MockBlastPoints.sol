// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IBlastPoints} from "src/interfaces/IBlastPoints.sol";

contract MockBlastPoints is IBlastPoints {
  function configurePointsOperator(address) external override {}
}
