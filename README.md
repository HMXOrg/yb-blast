# Yield Bearing Tokens on Blast

ybBLAST is a smart contract built to wrap auto-rebasing tokens on Blast, functioning similar to wstETH. The balances of all yield-bearing tokens will remain static, while the conversion rate to the actual underlying asset will continuously increase.

ybBLAST consists of:

- **ybETH**: An ERC-4626 compatible token that wraps both WETH and ETH on Blast.

## ybBLAST Contract Addresses

| Token  | Address                                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------------------- |
| ybETH  | [0x2EAd9c6C7cAB1DD3442714A8A8533078C402135A](https://blastscan.io/address/0x2EAd9c6C7cAB1DD3442714A8A8533078C402135A) |
| ybUSDB | [0x620aa22aA45F59Af91CaFBAd0ab58181FcDBfB08](https://blastscan.io/address/0x620aa22aA45F59Af91CaFBAd0ab58181FcDBfB08) |

## Usage

### Running tests

```shell
$ forge test
```

## Licensing

The primary license for ybBLAST is the MIT License, see [License](https://github.com/HMXOrg/yb-blast/blob/master/LICENSE) for more details.
