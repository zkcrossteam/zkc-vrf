import { expect } from "chai";
import * as constants from "./const.ts";
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
    const proxy = await Proxy.deploy(constants.adminAddr); //sepolia
    await proxy.deployed();
    console.log("zkcvrf address: ", proxy.address);

    const Example = await hre.ethers.getContractFactory("zkcvrf_example");
    const example = await Example.deploy(proxy.address); //sepolia
    await example.deployed();
    console.log("zkcvrf_example address: ", example.address);

    console.log("setup completed!");
    return;
}
