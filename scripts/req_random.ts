import { expect } from "chai";
const { ethers } = require("hardhat");
const BN = require('bn.js');

const helpers = require("@nomicfoundation/hardhat-network-helpers");

async function main() {
    await req_random();
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

async function req_random() {
    const contract = await ethers.getContractAt("zkcvrf_example", "0xaA1A2Faa1DB90968Bf4E86a6FB913b8B267cff0C");

    const tx  = await contract.request_random(0x0, 0x5678);
    console.log(tx);
    await tx.wait();
}
