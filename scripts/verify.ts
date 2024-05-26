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
    const contract = await ethers.getContractAt("zkcvrf", "0xCe1A3cd005F5B7937c9B6A4dDC514603F90C349D");
 
    let helper = new ZkWasmServiceHelper("https://rpc.zkwasmhub.com:8090", "", "");
    let log: QueryParams = {
        user_address: "0xefc304a114398ed8eb2b4caafe7deeaea666e6e5",
	md5: "F9A36A5DCE90EA6B1BD6F6A72928D6E4",
        id: "66528b5ba27375b8e521907f",
        tasktype: "Prove",
        taskstatus: "Done",
    }

    let tasks = await helper.loadTasks(log);
    if (tasks.data.length > 0) {
        let data0 = tasks.data[0];
        let proof = data0.proof;
        let aux = data0.aux;
	// See below for an example of verifying a proof which has been batched with the Auto Submitted Proof service.

        let batchInstances = data0.shadow_instances;
        let instances = data0.instances;

        let proofArr = new U8ArrayUtil(proof).toNumber();
        let auxArr = new U8ArrayUtil(aux).toNumber();
        let verifyInstancesArr = new U8ArrayUtil(batchInstances).toNumber();
	//console.log(instances);
        let instArr = new U8ArrayUtil(instances).toNumber();
	console.log(instArr);

	const byteArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 52, 86, 120, 146, 98, 52, 254, 59, 129, 204, 175, 59, 217, 116, 151, 121, 211, 195, 97, 243, 0, 129, 251, 243, 84, 10, 155, 57, 128, 81, 18, 205, 62, 13, 11, 153, 127, 135]

        const tx  = await contract.fullfill_random(byteArray, proofArr, verifyInstancesArr, auxArr, [instArr]);
        console.log(tx);
        await tx.wait();
    }
}
