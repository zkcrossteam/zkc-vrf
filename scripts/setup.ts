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
    const Proxy = await hre.ethers.getContractFactory("ZKVRFCoordinator");
    const proxy = await Proxy.deploy(); //sepolia
    await proxy.deployed();
    console.log("zkcvrf address: ", proxy.address);

    const Example = await hre.ethers.getContractFactory("zkvrf_example");
    const example = await Example.deploy(proxy.address); //sepolia
    await example.deployed();
    console.log("zkvrf_example address: ", example.address);

    console.log("setup completed!");
    return;
}
