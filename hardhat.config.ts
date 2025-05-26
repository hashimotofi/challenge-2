import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "dotenv/config";

// This file needs to be completed by the candidate as part of Task 1

// Candidate should use environment variables for private keys and API keys
// Hardhat will automatically read from .env file
// Sample reference:
// const PRIVATE_KEY = process.env.PRIVATE_KEY || "0x0000000000000000000000000000000000000000000000000000000000000000";

// The networks section should be completed by the candidate
// with Plume testnet configuration
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    // Plume testnet configuration to be added by candidate
  
    hardhat: {
      chainId: 31337
    }
  },
  
  // Ensure gas reporter is configured
};

export default config;
