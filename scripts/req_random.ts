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
    const contract = await ethers.getContractAt("zkcvrf_example", "0x223Ed6e783E6A275e50A6EeDb8F9177d7782601D");

    // const tx  = await contract.request_random(0x1, 0x5678);
     const tx  = await contract.request_random(ethers.BigNumber.from(12).shl(192).add(ethers.BigNumber.from(34).shl(128)).add(ethers.BigNumber.from(56).shl(64)).add(ethers.BigNumber.from(78)), 0x5678);
    console.log(tx);
    await tx.wait();
}
