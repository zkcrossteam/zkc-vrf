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
    const contract = await ethers.getContractAt("zkcvrf_example", "0x6FA3E7b92F1Ddaf592604a82681D56176DC1826f");

    const tx  = await contract.request_random(5124095575482932, 123456);
    console.log(tx);
    await tx.wait();
}
