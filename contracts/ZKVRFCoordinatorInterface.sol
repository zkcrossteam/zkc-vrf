// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ZKVRFCoordinatorInterface {
    function requestRandomWords(uint256 orig_seed, uint256 operate_group_hash, address callback) external returns (uint256);
}
