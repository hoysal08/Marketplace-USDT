require("@nomicfoundation/hardhat-toolbox");
// hardhat.config.js
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config()

const { API_URL, PRIVATE_KEY,ETH_SCAN_API_KEY } = process.env

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
};

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: API_URL,
        blockNumber: 8414109
      }
    },
    goerli: {
      url: API_URL,
      accounts: [ PRIVATE_KEY] 
    }
  },
  etherscan: {
    apiKey: ETH_SCAN_API_KEY,
  },
  solidity: {
    compilers: [
      {
        version: "0.5.0",
      },
      {
        version: "0.8.2",
      },
      {
        version: "0.6.6",
      },
    ],
  },
};