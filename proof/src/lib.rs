use zkwasm_rust_sdk::wasm_output;
use sha2::{Sha256, Digest};

pub struct RandomInfo {
    pub seed: [u64; 4],
    pub random: [u64; 4],
}

impl RandomInfo {
    pub fn new(
        seed: [u64; 4],
        random: [u64; 4],
    ) -> Self {
        RandomInfo {
            seed,
            random,
        }
    }
    /// change everything to big endian that should fits solidity's format
    pub fn to_be_bytes(&self) -> [u8; 80] {
        let mut bytes = vec![];
        for i in 0..4 {
            bytes.append(&mut self.seed[3-i].to_be_bytes().to_vec());
        }
        for i in 0..4 {
            bytes.append(&mut self.random[3-i].to_be_bytes().to_vec());
        }
        bytes.try_into().unwrap()
    }
}

/// encode bytes into wasm output
pub fn output_tx_info(data: &[u8; 80]) {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    for c in result.chunks_exact(8) {
        zkwasm_rust_sdk::dbg!("c is {:?}", c);
        unsafe { wasm_output(u64::from_le_bytes(c.try_into().unwrap())) }
    }
}

mod zkmain;
