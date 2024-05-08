// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./VerifierIface.sol";
import "./zkcvrfCallbackIface.sol";
import "./zkcvrfIface.sol";

contract zkcvrf is zkcvrfIface {
    mapping(uint256 => address[2]) public smap;
    event Request(uint256 seed, uint256 group_hash);
    event Settle(uint256 seed, uint256 randomNumber);
    address verifier = 0x56Ac4A0981cD36e07Fb6A3F6cde5FdBFAf89EA02; //sepolia

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

    // Verify with seed, randomNumber and proof
    // If verify succeed, run callback
    function settle_random(
        uint256 seed,
        uint256 randomNumber,
        uint256[] calldata proof,
        uint256[] calldata verify_instance,
        uint256[] calldata aux,
        uint256[][] calldata instances
    ) public {
        require(smap[seed][0] != address(0), "Seed not found");

        DelphinusVerifier(verifier).verify(proof, verify_instance, aux, instances);
	//Or should we get randomNumber from instances after verify?

        emit Settle(seed, randomNumber);
        zkcvrfCallbackIface(smap[seed][0]).handle_random(seed, randomNumber);

        // Delete seed after callback
        delete smap[seed];
    }
}
