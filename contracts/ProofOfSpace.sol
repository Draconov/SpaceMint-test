// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofOfSpace {
    struct Miner {
        bytes32 commitment; // Hash of the storage proof
        uint256 spaceSize; // Space committed (in GB, for example)
        bool hasProven; // Has the miner proven storage?
    }

    mapping(address => Miner) public miners;
    mapping(address => uint256) public rewards;
    uint256 public totalRewards = 1000 ether; // Reward pool

    event SpaceCommitted(address indexed miner, uint256 spaceSize, bytes32 commitment);
    event ProofSubmitted(address indexed miner, bool valid, uint256 reward);

    // Miner commits space
    function commitSpace(bytes32 _commitment, uint256 _spaceSize) external {
        require(miners[msg.sender].commitment == bytes32(0), "Already committed");
        miners[msg.sender] = Miner(_commitment, _spaceSize, false);
        emit SpaceCommitted(msg.sender, _spaceSize, _commitment);
    }

    // Miner submits proof for verification
    function submitProof(bytes32 _proof) external {
        require(miners[msg.sender].commitment != bytes32(0), "No commitment found");
        require(!miners[msg.sender].hasProven, "Already proven");

        bool isValid = _proof == miners[msg.sender].commitment;
        if (isValid) {
            miners[msg.sender].hasProven = true;
            uint256 reward = miners[msg.sender].spaceSize * 1 ether; // 1 ETH per GB
            rewards[msg.sender] += reward;
            totalRewards -= reward;
        }

        emit ProofSubmitted(msg.sender, isValid, isValid ? rewards[msg.sender] : 0);
    }

    // Check miner's reward balance
    function getRewardBalance() external view returns (uint256) {
        return rewards[msg.sender];
    }
}