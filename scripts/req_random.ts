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
    const contract = await ethers.getContractAt("zkcvrf_example", "0xC81e2aEd4619B931f0EFf625c478db3162Dd8B06");

    const tx  = await contract.request_random(0x9123452, 0x5678);
    console.log(tx);
    await tx.wait();
}
