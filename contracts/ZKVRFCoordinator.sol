// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./VerifierIface.sol";
import "./ZKVRFConsumerBase.sol";
import "./ZKVRFCoordinatorInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ZKVRFCoordinator is ZKVRFCoordinatorInterface, Ownable, ReentrancyGuard {
    event Request(uint256 requestId, uint256 seed, uint256 group_hash);
    event Settle(uint256 requestId, uint256 seed, uint256 operate_group_hash, uint256 randomNumber);
    address verifier = 0x2cd0a24aCAC1ee774443A28BD28C46E2D8e3a091; //del-sepolia
    struct RequestInfo {
	uint256 orig_seed;
	address callback;
	uint256 operate_group_hash;
        uint256 start_block;
    }
    mapping(uint256 => RequestInfo) public smap;
    uint256 public nextRequestId;

    constructor() Ownable(msg.sender) {
    }

    function requestRandomWords(uint256 orig_seed, uint256 operate_group_hash, address callback) public nonReentrant returns (uint256) {
        uint256 requestId = nextRequestId++;
	uint256 seed;

        seed = uint256(keccak256(abi.encode(keccak256(abi.encode(orig_seed)), requestId)));
	smap[requestId] = RequestInfo({
		orig_seed: orig_seed,
		callback:callback,
		operate_group_hash:operate_group_hash,
		start_block:block.number});

        emit Request(requestId, seed, operate_group_hash);
	return requestId;
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

    function fulfillRandomWords(
        uint256 requestId,
	bytes calldata tx_data,
        uint256[] calldata proof,
        uint256[] calldata verify_instance,
        uint256[] calldata aux,
        uint256[][] calldata instances
    ) public nonReentrant {
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

        require(smap[requestId].callback != address(0), "Request not found");
        require(seed ==	uint256(keccak256(abi.encode(keccak256(abi.encode(smap[requestId].orig_seed)), requestId))), "Seed not mismatch");
        require(smap[requestId].operate_group_hash == (instances[0][0] << 192) + (instances[0][1] << 128) + (instances[0][2] << 64) + (instances[0][3]), "Grouphash mismatch");

        DelphinusVerifier(verifier).verify(proof, verify_instance, aux, instances);

        emit Settle(requestId, seed, smap[requestId].operate_group_hash, randomNumber);
        ZKVRFConsumerBase(smap[requestId].callback).rawFulfillRandomWords(requestId, smap[requestId].orig_seed, randomNumber);

        // Delete seed after callback
        delete smap[requestId];
    }

    function setVerifier(address vaddr) public onlyOwner {
        verifier = vaddr;
    }
}
