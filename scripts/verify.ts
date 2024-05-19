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
    const contract = await ethers.getContractAt("zkcvrf", "0x19cF9C6c1c2F596A3F9f307Ea4fC4BEe39bFb6E6");
 
    let helper = new ZkWasmServiceHelper("https://rpc.zkwasmhub.com:8090", "", "");
    let log: QueryParams = {
        user_address: "0x5cd293a257ad7d6E37DA47547b4a860665Bbb562",
        md5: "4ACF8785C72DA630F963700FF60198CC",
        id: "662ed7b156e94dd72559ce75",
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
	console.log(instances);
        let instArr = new U8ArrayUtil(instances).toNumber();
	console.log(instArr);

        const tx  = await contract.settle_random(0x12345, 0x5678, proofArr, verifyInstancesArr, auxArr, [instArr]);
        console.log(tx);
        await tx.wait();
    }
}
