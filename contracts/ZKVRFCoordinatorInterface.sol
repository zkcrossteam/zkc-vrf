// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ZKVRFCoordinatorInterface {
    function requestRandomWords(uint256 seed, address callback, uint256 group_hash) external returns (uint256[2] memory);
}
