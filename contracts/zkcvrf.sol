// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./VerifierIface.sol";
import "./zkcvrfCallbackIface.sol";
import "./zkcvrfIface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "hardhat/console.sol";

contract zkcvrf is zkcvrfIface {
    using SafeERC20 for IERC20;
    event Request(uint256 seed, uint256 group_hash);
    event Settle(uint256 seed, uint256 randomNumber);
    address verifier = 0xCec4ECd9B4DCc874E711c9AAd9Be8074B210e3A3; //sepolia
    struct RequestInfo {
	address callback;
	uint256 groupPk;
        uint256 start_block;
    }
    mapping(uint256 => RequestInfo) public smap; //mapping seed to requestInfo

    address public treasury; // Define treasury address
    address stakeToken = 0xCec4ECd9B4DCc874E711c9AAd9Be8074B210e3A3; // Define ERC20Token contract

    struct GroupInfo {
        uint256 stakeBalance;
        address creatorAddr;
	uint256[] pending_seeds;
    }
    mapping(uint256 => GroupInfo) public groups;
    uint256[] public groupKeys; // Array to store keys of groups mapping
    uint256 constant GROUP_MIN_STAKE_AMOUNT = 100 ether;
    uint256 constant GROUP_MIN_AMOUNT = 20 ether;

    constructor() {}

    // Mapping a seed to a callback contract's address and
    // generate random number with the keccak256 hash algorithm
    // mapping seed to verify contract's address
    function create_random(uint256 seed, address callback, uint256 group_hash) public returns (uint256[2] memory){
        require(smap[seed].callback == address(0), "Seed already exists");

        smap[seed] = RequestInfo({callback:callback,groupPk:group_hash,start_block:block.number});
	//add to group
	require(groups[group_hash].stakeBalance >= GROUP_MIN_AMOUNT, "group stake balance is not enough");
	groups[group_hash].pending_seeds.push(seed);

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
        require(smap[seed].callback != address(0), "Seed not found");
        require(smap[seed].groupPk != (instances[0][4] << 192) + (instances[0][5] << 128) + (instances[0][6] << 64) + (instances[0][7]), "Grouphash not match");

        DelphinusVerifier(verifier).verify(proof, verify_instance, aux, instances);

        emit Settle(seed, randomNumber);
        zkcvrfCallbackIface(smap[seed].callback).handle_random(seed, randomNumber);

	//Delete seed from group
	uint256[] storage pending_seeds = groups[seed].pending_seeds;
	for (uint256 i = 0; i < pending_seeds.length; i++) {
	    if (pending_seeds[i] == seed) {
  	        pending_seeds[i] = pending_seeds[pending_seeds.length - 1];
                pending_seeds.pop();
                break;
	    }
	}

        // Delete seed after callback
        delete smap[seed];
    }

    function registerGroup(uint256 pk, uint256 balance) external {
        require(balance >= GROUP_MIN_STAKE_AMOUNT, "Insufficient balance");
	require(groups[pk].stakeBalance == 0, "Group pk already exists.");

        groups[pk] = GroupInfo({
            stakeBalance: balance,
	    creatorAddr: msg.sender,
            pending_seeds: new uint256[](0)
        });
        groupKeys.push(pk); // Add the pk to the array of group keys
    
        IERC20(stakeToken).safeTransferFrom(msg.sender, address(this), balance);
    }

    function updateGroupBalance(uint256 pk, uint256 balance) external {
	require(groups[pk].stakeBalance != 0, "Group pk not exists.");
	require(msg.sender == groups[pk].creatorAddr, "Not creator");

	groups[pk].stakeBalance += balance;
        IERC20(stakeToken).safeTransferFrom(msg.sender, address(this), balance);
    }
    
    function updateGroupPk(uint256 oldPk, uint256 newPk) external {
        require(groups[oldPk].stakeBalance != 0, "Group pk not found.");
	require(msg.sender == groups[oldPk].creatorAddr, "Not creator");
	require(groups[oldPk].pending_seeds.length == 0, "Has pending request");

        // Update the group's pk in the mapping
        groups[newPk] = groups[oldPk];
        delete groups[oldPk];

        // Update the key in the array of group keys
        for (uint256 i = 0; i < groupKeys.length; i++) {
            if (groupKeys[i] == oldPk) {
                groupKeys[i] = newPk;
                break;
            }
        }
    }

    function deleteGroupByPk(uint256 pk) external {
        require(groups[pk].stakeBalance != 0, "Group pk not found.");
	require(msg.sender == groups[pk].creatorAddr, "Not creator");

        // Remove the pk from the array of group keys
        for (uint256 i = 0; i < groupKeys.length; i++) {
            if (groupKeys[i] == pk) {
                groupKeys[i] = groupKeys[groupKeys.length - 1];
                groupKeys.pop();
                break;
            }
        }
        IERC20(stakeToken).safeTransferFrom(address(this), groups[pk].creatorAddr, groups[pk].stakeBalance);
        // Delete the group from the mapping
        delete groups[pk];
    }

    event slashEvent(uint256 seed, uint256 pk, uint256 amount, uint256 blockOffer); // Define the event

    function slashGroup() external {
        uint256 currentBlock = block.number;

	for (uint256 i = 0; i < groupKeys.length; i++) { 
		GroupInfo memory currentGroup = groups[groupKeys[i]];
		for (uint256 j = 0; j < currentGroup.pending_seeds.length; j++) {
			uint256 seed = currentGroup.pending_seeds[j];
			RequestInfo memory currentRequest = smap[seed];
			require(currentRequest.groupPk == groupKeys[i],	"groupPk mismatch");

			if (currentBlock - currentRequest.start_block > 10) {
                            uint256 amount = (currentGroup.stakeBalance * 2) / 100;
                            IERC20(stakeToken).safeTransfer(treasury, amount);
                            emit slashEvent(seed, currentRequest.groupPk, amount, currentRequest.start_block);
			}
 		  	if (currentBlock - currentRequest.start_block > 20) {
                            uint256 amount = (currentGroup.stakeBalance * 2) / 100;
                            IERC20(stakeToken).safeTransfer(treasury, amount);
                            emit slashEvent(seed, currentRequest.groupPk, amount, currentRequest.start_block);
			}
		}
	}
    }
}

