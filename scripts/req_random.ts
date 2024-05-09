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
    const contract = await ethers.getContractAt("zkcvrf_example", "0x9285E0B12e0415664b4A2049D8440BF6E593bC80");

    const tx  = await contract.request_random(0x12345, 0x5678);
    console.log(tx);
    await tx.wait();
}
