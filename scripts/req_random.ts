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
   const contract = await ethers.getContractAt("zkcvrf_example", "0x0C05BaCD83E16C74C3aC219BAe5309D0Bda10dAE");

   const arg1 = ethers.BigNumber.from("5154095575442842");
  const arg2 = ethers.BigNumber.from("38608566209366443851658898712947698042272167288516776474471539454638392565090");

    const tx  = await contract.request_random(arg1,arg2);
    console.log(tx);
    await tx.wait();
}
