use primitive_types::U256;
use zkwasm_rust_sdk::jubjub::BabyJubjubPoint;
use zkwasm_rust_sdk::jubjub::JubjubSignature;
use zkwasm_rust_sdk::wasm_input;
use zkwasm_rust_sdk::wasm_output;

use wasm_bindgen::prelude::*;

use sha2::{Digest, Sha256};
use crate::RandomInfo;
use crate::output_tx_info;

#[wasm_bindgen]
pub fn zkmain() -> i64 {
    let mut hasher = Sha256::new();

    let commands_len = unsafe { wasm_input(0) };
    
    let mut seed_inputs = vec![];
    // get the seed and hash to a msg for sign

    let mut i = 0;
    for _ in 0..commands_len {
        let command = unsafe { wasm_input(0) };
        hasher.update(command.to_le_bytes());
        if i < 4 {
            seed_inputs.push(command);
        }
        i += 1;
    }
    if commands_len < 4 {
        for _ in 0..(4 - commands_len) {
            seed_inputs.push(0);
        }
    }

    let msghash = hasher.finalize();
    zkwasm_rust_sdk::dbg!("command hash is {:?}\n", msghash);

    let msghash_u64 = [
        u64::from_be_bytes(msghash[24..32].try_into().unwrap()),
        u64::from_be_bytes(msghash[16..24].try_into().unwrap()),
        u64::from_be_bytes(msghash[8..16].try_into().unwrap()),
        u64::from_be_bytes(msghash[0..8].try_into().unwrap()),
    ];

    let signer_len = unsafe { wasm_input(0) };
    let mut random = Sha256::new();
    let mut group = Sha256::new();

    for _ in 0..signer_len {
        let pk = unsafe {
            BabyJubjubPoint {
                x: U256([wasm_input(0), wasm_input(0), wasm_input(0), wasm_input(0)]),
                y: U256([wasm_input(0), wasm_input(0), wasm_input(0), wasm_input(0)]),
            }
        };
        zkwasm_rust_sdk::dbg!("process sig\n");

        let sig = unsafe {
            JubjubSignature {
                sig_r: BabyJubjubPoint {
                    x: U256([wasm_input(0), wasm_input(0), wasm_input(0), wasm_input(0)]),
                    y: U256([wasm_input(0), wasm_input(0), wasm_input(0), wasm_input(0)]),
                },
                sig_s: [wasm_input(0), wasm_input(0), wasm_input(0), wasm_input(0)],
            }
        };
        zkwasm_rust_sdk::dbg!("start verifying ...\n");
        sig.verify(&pk, &msghash_u64);

        // update the random value
        random.update(sig.sig_s[0].to_le_bytes());
        random.update(sig.sig_s[1].to_le_bytes());
        random.update(sig.sig_s[2].to_le_bytes());
        random.update(sig.sig_s[3].to_le_bytes());

        // update the group pubkey hash
        group.update(pk.x.0[0].to_le_bytes());
        group.update(pk.x.0[1].to_le_bytes());
        group.update(pk.x.0[2].to_le_bytes());
        group.update(pk.x.0[3].to_le_bytes());
    }

    let random = random.finalize();
    let group = group.finalize();

    // convert to bigendian u64
    let random_u64 = [
        u64::from_be_bytes(random[24..32].try_into().unwrap()),
        u64::from_be_bytes(random[16..24].try_into().unwrap()),
        u64::from_be_bytes(random[8..16].try_into().unwrap()),
        u64::from_be_bytes(random[0..8].try_into().unwrap()),
    ];

    zkwasm_rust_sdk::dbg!("generated random is {:?}", random_u64);

    let group_u64 = [
        u64::from_be_bytes(group[24..32].try_into().unwrap()),
        u64::from_be_bytes(group[16..24].try_into().unwrap()),
        u64::from_be_bytes(group[8..16].try_into().unwrap()),
        u64::from_be_bytes(group[0..8].try_into().unwrap()),
    ];


    unsafe {
        wasm_output(group_u64[0]);
        wasm_output(group_u64[1]);
        wasm_output(group_u64[2]);
        wasm_output(group_u64[3]);
    }

    let deposit = RandomInfo::new(
        [seed_inputs[0], seed_inputs[1], seed_inputs[2], seed_inputs[3]],
        [random_u64[0], random_u64[1], random_u64[2], random_u64[3]]
    );

    output_tx_info(&deposit.to_be_bytes());

    0
}
