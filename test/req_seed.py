from web3 import Web3
import asyncio
from dotenv import load_dotenv
import os
import random
import argparse

# Load environment variables from .env file
load_dotenv()

# Get variables from environment
private_key = os.getenv('PRIVATE_KEY')
from_address = os.getenv('FROM_ADDRESS')
rpc_url = os.getenv('RPC_URL')
contract_address = os.getenv('CONTRACT_ADDRESS')

# Initialize Web3 with the RPC URL
w3 = Web3(Web3.HTTPProvider(rpc_url))

# Define the simplified ABI for zkvrf_example contract
contract_abi = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "seed",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "group_hash",
                "type": "uint256"
            }
        ],
        "name": "request_random",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_requestId",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "seed",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "randomNumber",
                "type": "uint256"
            }
        ],
        "name": "fulfillRandomWords",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

async def req_random(group_hash):
    contract = w3.eth.contract(address=contract_address, abi=contract_abi)

    # Generate a random integer seed using Python's random functions
    seed = random.randint(1, 2**256 - 1)

    tx = contract.functions.request_random(
        seed,
        group_hash
    ).build_transaction({
        'from': from_address,
        'gas': 2000000,
        'gasPrice': w3.eth.gas_price,
        'nonce': w3.eth.get_transaction_count(from_address),
    })

    signed_tx = w3.eth.account.sign_transaction(tx, private_key)
    tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)

    print(f"Transaction hash: {tx_hash.hex()}")

    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    print("Transaction receipt:", receipt)

    tx_status = w3.eth.get_transaction_receipt(tx_hash)
    print("Transaction status:", tx_status)

async def main():
    parser = argparse.ArgumentParser(description="Send a random request to the zkvrf_example contract.")
    parser.add_argument('group_hash', type=int, help='The group hash to use in the request_random function.')

    args = parser.parse_args()
    
    try:
        await req_random(args.group_hash)
    except Exception as error:
        print("Error:", error)
        exit(1)

if __name__ == "__main__":
    asyncio.run(main())

