// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./VerifierIface.sol";
import "./zkcvrfCallbackIface.sol";
import "./zkcvrfIface.sol";
//import "hardhat/console.sol";

contract zkcvrf is zkcvrfIface {
    mapping(uint256 => address[2]) public smap;
    event Request(uint256 seed, uint256 group_hash);
    event Settle(uint256 seed, uint256 randomNumber);
    address verifier = 0xCec4ECd9B4DCc874E711c9AAd9Be8074B210e3A3; //sepolia

    constructor() {}

    // Mapping a seed to a callback contract's address and
    // generate random number with the keccak256 hash algorithm
    // mapping seed to verify contract's address
    function create_random(uint256 seed, address callback, uint256 group_hash) public returns (uint256[2] memory){
        require(smap[seed][0] == address(0), "Seed already exists");

        smap[seed] = [callback, address(0)];

        emit Request(seed, group_hash);

        // Calculate random number with more random values, such as msg.sender and block.timestamp
        // Return block.timestamp for testing
        return [block.timestamp, uint256(keccak256(abi.encodePacked(seed, msg.sender, block.timestamp)))];
    }

    function bytesToUint(bytes memory bs, uint256 start, uint256 len)
        internal
        pure
        returns (uint256)
    {
        require(bs.length >= start + 32, "slicing out of range");
        uint256 x;
        assembly {
            x := mload(add(bs, add(start, 0x20)))
        }
        return x >> (32 - len) * 8;
    }

    function fullfill_random(
	bytes calldata tx_data,
        uint256[] calldata proof,
        uint256[] calldata verify_instance,
        uint256[] calldata aux,
        uint256[][] calldata instances
    ) public {

        uint256 sha_pack = uint256(sha256(tx_data));
        require(
            sha_pack ==
                (instances[0][8] << 192) +
                    (instances[0][9] << 128) +
                    (instances[0][10] << 64) +
                    instances[0][11],
            "Inconstant: Sha data inconsistant"
        );

	uint256 seed = bytesToUint(tx_data, 0, 32);
	uint256 randomNumber = bytesToUint(tx_data, 32, 32);
        require(smap[seed][0] != address(0), "Seed not found");

        DelphinusVerifier(verifier).verify(proof, verify_instance, aux, instances);

        emit Settle(seed, randomNumber);
        zkcvrfCallbackIface(smap[seed][0]).handle_random(seed, randomNumber);

        // Delete seed after callback
        delete smap[seed];
    }
}
