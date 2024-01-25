# Yield Bearing Tokens on Blast

ybBLAST is a smart contract built to wrap auto-rebasing tokens on Blast, functioning similar to wstETH. The balances of all yield-bearing tokens will remain static, while the conversion rate to the actual underlying asset will continuously increase.

ybBLAST consists of:

- **ybETH**: An ERC-4626 compatible token that wraps both WETH and ETH on Blast.

## ybBLAST Contract Addresses

| Chain         | Address                                                                                                                       |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Blast Sepolia | [0xA0e4944b2f953c2E76872E84F9CC89AE94bC70e8](https://testnet.blastscan.io/address/0xA0e4944b2f953c2E76872E84F9CC89AE94bC70e8) |

## Usage

### Running tests

```shell
$ forge test
```

## Licensing

The primary license for ybBLAST is the MIT License, see [License](https://github.com/HMXOrg/yb-blast/blob/master/LICENSE) for more details.
