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
    const contract = await ethers.getContractAt("zkcvrf_example", "0x71A4DbB7148b3ebE018f12b267650b674D3BB550");

    const tx  = await contract.request_random(5124095575482932, 123456);
    console.log(tx);
    await tx.wait();
}
