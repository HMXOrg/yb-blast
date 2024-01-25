// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Libraries
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "lib/solmate/src/utils/FixedPointMathLib.sol";

// Interfaces
import {IBlast, YieldMode} from "src/interfaces/IBlast.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

contract ybETH is ERC20 {
  using SafeTransferLib for address;
  using SafeTransferLib for ERC20;
  using SafeTransferLib for IWETH;
  using FixedPointMathLib for uint256;

  // Errors
  error ZeroAssets();
  error ZeroShares();

  // Configs
  IWETH public immutable weth;
  IBlast public immutable blast;

  // States
  uint256 internal _totalAssets;

  // Events
  event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
  event Withdraw(
    address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
  );

  constructor(IWETH _weth, IBlast _blast) ERC20("ybETH", "ybETH", 18) {
    // Effect
    weth = _weth;
    blast = _blast;

    // Interaction
    blast.configureClaimableYield();
  }

  function asset() external pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  }

  /// @notice Claim all pending yield from the wethRebasing contract and update totalAssets.
  function claimAllYield() public {
    _totalAssets += blast.claimAllYield(address(this), address(this));
  }

  function depositETH(address _receiver) public payable returns (uint256 _shares) {
    // Claim all pending yield
    claimAllYield();

    // Check for rounding error.
    if ((_shares = previewDeposit(msg.value)) == 0) revert ZeroShares();

    // Effect
    // Update totalAssets
    _totalAssets += msg.value;
    // Mint ybETH
    _mint(_receiver, _shares);

    // Log
    emit Deposit(msg.sender, _receiver, msg.value, _shares);
  }

  function deposit(uint256 _assets, address _receiver) external returns (uint256 _shares) {
    // Claim all pending yield
    claimAllYield();

    // Check for rounding error.
    if ((_shares = previewDeposit(_assets)) == 0) revert ZeroShares();

    // Transfer from depositor
    weth.safeTransferFrom(msg.sender, address(this), _assets);
    weth.withdraw(_assets);

    // Effect
    // Update totalAssets
    _totalAssets += _assets;
    // Mint ybETH
    _mint(_receiver, _shares);

    // Log
    emit Deposit(msg.sender, _receiver, _assets, _shares);
  }

  function mint(uint256 _shares, address _receiver) external returns (uint256 _assets) {
    // Claim all pending yield
    claimAllYield();

    _assets = previewMint(_shares);

    // Transfer from depositor
    weth.safeTransferFrom(msg.sender, address(this), _assets);
    weth.withdraw(_assets);

    // Effect
    // Update totalAssets
    _totalAssets += _assets;
    // Mint ybETH
    _mint(_receiver, _shares);

    // Log
    emit Deposit(msg.sender, _receiver, _assets, _shares);
  }

  function _redeem(bool _isEthOut, uint256 _shares, address _receiver, address _owner)
    internal
    returns (uint256 _assets)
  {
    // Claim all pending yield
    claimAllYield();

    if (msg.sender != _owner) {
      // If msg.sender is not the owner, then check allowance
      uint256 _allowed = allowance[_owner][msg.sender];
      if (_allowed != type(uint256).max) {
        // If not unlimited allowance, then decrease allowance.
        // This should be reverted if the allowance is not enough.
        allowance[_owner][msg.sender] = _allowed - _shares;
      }
    }

    // Check for rounding error.
    if ((_assets = previewRedeem(_shares)) == 0) revert ZeroAssets();

    // Effect
    _burn(_owner, _shares);
    _totalAssets -= _assets;

    // Interaction
    // Transfer assets out
    if (_isEthOut) {
      address(_receiver).safeTransferETH(_assets);
    } else {
      address(weth).safeTransferETH(_assets);
      weth.safeTransfer(_receiver, _assets);
    }

    emit Withdraw(msg.sender, _receiver, _owner, _assets, _shares);
  }

  function redeemETH(uint256 _shares, address _receiver, address _owner) public returns (uint256 _assets) {
    return _redeem(true, _shares, _receiver, _owner);
  }

  function redeem(uint256 _shares, address _receiver, address _owner) public returns (uint256 _assets) {
    return _redeem(false, _shares, _receiver, _owner);
  }

  function _withdraw(bool _isEthOut, uint256 _assets, address _receiver, address _owner)
    public
    returns (uint256 _shares)
  {
    // Claim all pending yield
    claimAllYield();

    _shares = previewWithdraw(_assets);

    if (msg.sender != _owner) {
      // If msg.sender is not the owner, then check allowance
      uint256 _allowed = allowance[_owner][msg.sender];
      if (_allowed != type(uint256).max) {
        // If not unlimited allowance, then decrease allowance.
        // This should be reverted if the allowance is not enough.
        allowance[_owner][msg.sender] = _allowed - _shares;
      }
    }

    // Effect
    _burn(_owner, _shares);
    _totalAssets -= _assets;

    // Interaction
    // Transfer assets out
    if (_isEthOut) {
      address(_receiver).safeTransferETH(_assets);
    } else {
      address(weth).safeTransferETH(_assets);
      weth.safeTransfer(_receiver, _assets);
    }

    emit Withdraw(msg.sender, _receiver, _owner, _assets, _shares);
  }

  function withdrawETH(uint256 _assets, address _receiver, address _owner) public returns (uint256 _shares) {
    return _withdraw(true, _assets, _receiver, _owner);
  }

  function withdraw(uint256 _assets, address _receiver, address _owner) public returns (uint256 _shares) {
    return _withdraw(false, _assets, _receiver, _owner);
  }

  function totalAssets() public view returns (uint256) {
    return _totalAssets + blast.readClaimableYield(address(this));
  }

  function previewDeposit(uint256 _assets) public view returns (uint256 _shares) {
    return convertToShares(_assets);
  }

  function previewRedeem(uint256 _shares) public view returns (uint256 _assets) {
    return convertToAssets(_shares);
  }

  function previewMint(uint256 _shares) public view returns (uint256 _assets) {
    // SLOAD
    uint256 _totalSupply = totalSupply;
    return _totalSupply == 0 ? _shares : _shares.mulDivUp(totalAssets(), _totalSupply);
  }

  function previewWithdraw(uint256 _assets) public view returns (uint256 _shares) {
    // SLOAD
    uint256 _totalSupply = totalSupply;
    return _totalSupply == 0 ? _assets : _assets.mulDivUp(_totalSupply, totalAssets());
  }

  function convertToShares(uint256 _assets) public view returns (uint256 _shares) {
    // SLOAD
    uint256 _totalSupply = totalSupply;
    return _totalSupply == 0 ? _assets : _assets.mulDivDown(_totalSupply, totalAssets());
  }

  function convertToAssets(uint256 _shares) public view returns (uint256 _assets) {
    // SLOAD
    uint256 _totalSupply = totalSupply;
    return _totalSupply == 0 ? _shares : _shares.mulDivDown(totalAssets(), _totalSupply);
  }

  function maxDeposit(address) public pure returns (uint256) {
    return type(uint256).max;
  }

  function maxMint(address) public pure returns (uint256) {
    return type(uint256).max;
  }

  function maxWithdraw(address _owner) public view returns (uint256) {
    return convertToAssets(balanceOf[_owner]);
  }

  function maxRedeem(address _owner) public view returns (uint256) {
    return balanceOf[_owner];
  }

  receive() external payable {
    if (msg.sender != address(weth)) {
      depositETH(msg.sender);
    }
  }
}
