import { expect } from "chai";
const { ethers } = require("hardhat");
const BN = require('bn.js');

const helpers = require("@nomicfoundation/hardhat-network-helpers");

async function main() {
    await setup();
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

async function setup() {
    const Proxy = await hre.ethers.getContractFactory("zkcvrf");
    const proxy = await Proxy.deploy(); //sepolia
    await proxy.deployed();

    console.log("zkcvrf address: ", proxy.address);
    console.log("setup completed!");
    return;
}
