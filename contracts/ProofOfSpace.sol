// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofOfSpace {
    struct Miner {
        bytes32 commitment; // Hash of the storage proof commitment
        uint256 spaceSize; // Space committed in GB
        bool hasProven; // Has the miner proven their space?
    }

    mapping(address => Miner) public miners; // Mapping to track miner commitments
    mapping(address => uint256) public rewards; // Mapping to track miner rewards
    uint256 public totalRewards = 1000 ether; // Total reward pool

    // Events to track contract activity
    event SpaceCommitted(address indexed miner, uint256 spaceSize, bytes32 commitment);
    event ProofSubmitted(address indexed miner, bool valid, uint256 reward);

    // Miner commits space by submitting a hash and space size
    function commitSpace(bytes32 _commitment, uint256 _spaceSize) external {
        require(miners[msg.sender].commitment == bytes32(0), "Already committed");
        require(_spaceSize > 0, "Space size must be greater than zero");

        // Store the miner's commitment
        miners[msg.sender] = Miner(_commitment, _spaceSize, false);

        emit SpaceCommitted(msg.sender, _spaceSize, _commitment);
    }

    // Miner submits proof for validation
    function submitProof(bytes32 _proof) external {
        require(miners[msg.sender].commitment != bytes32(0), "No commitment found");
        require(!miners[msg.sender].hasProven, "Already proven");

        // Check if the submitted proof matches the commitment
        bool isValid = _proof == miners[msg.sender].commitment;
        require(isValid, "Invalid proof");

        // Mark as proven and allocate reward
        miners[msg.sender].hasProven = true;
        uint256 reward = miners[msg.sender].spaceSize * 1 ether; // 1 ETH per GB
        require(reward <= totalRewards, "Not enough rewards available");

        rewards[msg.sender] += reward;
        totalRewards -= reward;

        emit ProofSubmitted(msg.sender, isValid, reward);
    }

    // Miner checks their reward balance
    function getRewardBalance() external view returns (uint256) {
        return rewards[msg.sender];
    }
}