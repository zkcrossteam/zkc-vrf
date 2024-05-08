//require("@nomiclabs/hardhat-waffle");
//require("hardhat-typechain");
//require("@nomiclabs/hardhat-etherscan");
//require('@openzeppelin/hardhat-upgrades');

require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
    }
  },
  networks: {
    hardhat: {},
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/",
      accounts: [],
    },
    sepolia: {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts: ["privkey"]
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
      accounts: ["privkey"]
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
};
