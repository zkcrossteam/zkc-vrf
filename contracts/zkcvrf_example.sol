// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./ZKVRFConsumerBase.sol";
import "./ZKVRFCoordinatorInterface.sol";

contract zkcvrf_example is ZKVRFConsumerBase {
    event receiveRandom(uint256 seed, uint256 randomNumber);
    ZKVRFCoordinatorInterface _vrf;

    constructor(address _zkvrfCoordinator) ZKVRFConsumerBase(_zkvrfCoordinator) {
	_vrf = ZKVRFCoordinatorInterface(_zkvrfCoordinator);
    }

    function request_random(uint256 seed, uint256 group_hash) public {
	    _vrf.requestRandomWords(seed, address(this), group_hash);
    }

    function fulfillRandomWords(uint256 seed, uint256 randomNumber) internal override{
        emit receiveRandom(seed, randomNumber);
	//print (seed, randomNumber);
	//Use randome
    }
}
