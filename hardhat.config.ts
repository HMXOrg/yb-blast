import { config as dotEnvConfig } from "dotenv";
import { HardhatUserConfig } from "hardhat/config";

dotEnvConfig();

import * as tdly from "@tenderly/hardhat-tenderly";
tdly.setup({ automaticVerifications: false });

import "@openzeppelin/hardhat-upgrades";
import "hardhat-preprocessor";
import "@typechain/hardhat";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-verify";

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    blast_mainnet: {
      url: process.env.BLAST_RPC_URL || "",
      accounts: [process.env.MAINNET_PRIVATE_KEY!],
    },
    blast_sepolia: {
      url: process.env.BLAST_SEPOLIA_RPC_URL || "",
      chainId: 168587773,
      accounts: [process.env.MAINNET_PRIVATE_KEY!],
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 255,
      },
    },
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
    artifacts: "./artifacts",
  },
  typechain: {
    outDir: "./typechain",
    target: "ethers-v5",
  },
  etherscan: {
    apiKey: {
      blast_mainnet: process.env.BLASTSCAN_API_KEY!,
    },
    customChains: [
      {
        network: "blast_mainnet",
        chainId: 81457,
        urls: {
          apiURL: "https://api.blastscan.io/api",
          browserURL: "https://blastscan.io/",
        },
      },
    ],
  },
};

export default config;
