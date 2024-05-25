// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./zkcvrfCallbackIface.sol";
import "./zkcvrfIface.sol";

contract zkcvrf_example is zkcvrfCallbackIface {
    event receiveRandom(uint256 seed, uint256 randomNumber);
    zkcvrfIface _vrf;

    modifier onlyVrfContract() {
        require(msg.sender == address(_vrf), "Unauthorized access");
        _;
    }

    constructor(address _zkcvrf) {
	_vrf = zkcvrfIface(_zkcvrf);
    }

    function request_random(uint256 seed, uint256 group_hash) public {
	    _vrf.create_random(seed, address(this), group_hash);
    }

    function handle_random(uint256 seed, uint256 randomNumber) public onlyVrfContract {
        emit receiveRandom(seed, randomNumber);
	//print (seed, randomNumber);
	//Use randome
    }
}
 
