import {
    QueryParams,
    ZkWasmServiceHelper
} from "zkwasm-service-helper";
import { U8ArrayUtil} from './lib.ts'

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
    const contract = await ethers.getContractAt("zkcvrf", "0x0C46065A600624C23d373f6D40C93FB84c6bEa5E");
 
    let helper = new ZkWasmServiceHelper("https://rpc.zkwasmhub.com:8090", "", "");
    let log: QueryParams = {
        user_address: "0xefc304a114398ed8eb2b4caafe7deeaea666e6e5",
	md5: "7C51079B2672FD027F9F89ECD3DCF30E",
        id: "665026f0c1aab605af391eda",
        tasktype: "Prove",
        taskstatus: "Done",
    }

    let tasks = await helper.loadTasks(log);
    if (tasks.data.length > 0) {
        let data0 = tasks.data[0];
        let proof = data0.proof;
        let aux = data0.aux;
        let batchInstances = data0.batch_instances;
        let instances = data0.instances;

        let proofArr = new U8ArrayUtil(proof).toNumber();
        let auxArr = new U8ArrayUtil(aux).toNumber();
        let verifyInstancesArr = new U8ArrayUtil(batchInstances).toNumber();
	//console.log(instances);
        let instArr = new U8ArrayUtil(instances).toNumber();
	console.log(instArr);

	//const byteArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 123, 34, 63, 149, 165, 43, 176, 237, 165, 7, 208, 208, 76, 136, 219, 239, 220, 216, 189, 0, 144, 135, 235, 24, 56, 191, 52, 206, 191, 143, 26];

	const byteArray: number[] = [0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 1, 209, 241, 25, 155, 201, 46, 112, 232, 90, 238, 27, 69, 181, 135, 146, 88, 129, 242, 83, 162, 208, 159, 74, 178, 139, 197, 174, 1, 154, 143, 186, 245];

        const tx  = await contract.fullfill_random(byteArray, proofArr, verifyInstancesArr, auxArr, [instArr]);
        console.log(tx);
        await tx.wait();
    }
}
