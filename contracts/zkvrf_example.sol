// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./ZKVRFConsumerBase.sol";
import "./ZKVRFCoordinatorInterface.sol";

contract zkvrf_example is ZKVRFConsumerBase {
    event receiveRandom(uint256 _requestId, uint256 seed, uint256 randomNumber);
    ZKVRFCoordinatorInterface _vrf;
    uint256 requestId;

    constructor(address _zkvrfCoordinator) ZKVRFConsumerBase(_zkvrfCoordinator) {
	_vrf = ZKVRFCoordinatorInterface(_zkvrfCoordinator);
    }

    function request_random(uint256 seed, uint256 group_hash) public {
	requestId = _vrf.requestRandomWords(seed, group_hash, address(this));
    }

    function fulfillRandomWords(uint256 _requestId, uint256 seed, uint256 randomNumber) internal override{
	//require (_requestId == requestId, "request id mismatch");
	emit receiveRandom(_requestId, seed, randomNumber);
	//print (seed, randomNumber);
	//Use randome
    }
}
