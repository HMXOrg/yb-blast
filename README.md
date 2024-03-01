# Yield Bearing Tokens on Blast

ybBLAST is a smart contract built to wrap auto-rebasing tokens on Blast, functioning similar to wstETH. The balances of all yield-bearing tokens will remain static, while the conversion rate to the actual underlying asset will continuously increase.

ybBLAST consists of:

- **ybETH**: An ERC-4626 compatible token that wraps both WETH and ETH on Blast.
- **ybUSDB**: An ERC-4626 compatible token that wraps USDB on Blast.

## ybBLAST Contract Addresses

| Token  | Address                                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------------------- |
| ybETH  | [0xb9d94A3490bA2482E2D4F21F0E76b92E5661Ded8](https://blastscan.io/address/0xb9d94A3490bA2482E2D4F21F0E76b92E5661Ded8) |
| ybUSDB | [0xCD732d21c1B23A3f84Bb386E9759b5b6A1BcBe39](https://blastscan.io/address/0xCD732d21c1B23A3f84Bb386E9759b5b6A1BcBe39) |

## Usage

### Running tests

```shell
$ forge test
```

## Licensing

The primary license for ybBLAST is the MIT License, see [License](https://github.com/HMXOrg/yb-blast/blob/master/LICENSE) for more details.
