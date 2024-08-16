import { expect } from "chai";
const { ethers } = require("hardhat");
const bn = require('bn.js');

const helpers = require("@nomicfoundation/hardhat-network-helpers");

async function main() {
    await req_random();
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

async function req_random() {
   const contract = await ethers.getContractAt("zkvrf_example", "0x0601B5f1e2067fD304A9D27C4bF95d22c5044bfe");

   const arg1 = ethers.BigNumber.from("5154095575442842");
   const arg2 = ethers.BigNumber.from("106651045272248281329034530416119353156388698457438994187042521815273962483711");

    const tx  = await contract.request_random(arg1,arg2);
    console.log(tx);
    await tx.wait();
}
