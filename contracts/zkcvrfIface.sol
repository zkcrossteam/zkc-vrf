// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface zkcvrfIface {
    function create_random(uint256 seed, address callback, uint256 group_hash) external returns (uint256[2] memory);
}
