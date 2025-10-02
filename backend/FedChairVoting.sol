// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "fhevm/lib/fhevm.sol";

contract FedChairVoting {
    string[] public candidates;
    mapping(uint8 => euint32) public encryptedVotes;
    address public owner;
    uint256 public votingEndTimestamp;
    bool public resultsRevealed;
    mapping(address => bool) public hasVoted;
    uint32[] public results;

    event VoteCasted(address indexed voter);
    event ResultsRevealed(string[] finalCandidates, uint32[] finalResults);

    constructor(string[] memory _candidateNames, uint _votingDurationInSeconds) {
        owner = msg.sender;
        candidates = _candidateNames;
        votingEndTimestamp = block.timestamp + _votingDurationInSeconds;
        for (uint8 i = 0; i < candidates.length; i++) {
            encryptedVotes[i] = euint32(0);
        }
    }

    function vote(bytes calldata encryptedChoice) public {
        require(block.timestamp < votingEndTimestamp, "Voting has already ended.");
        require(!hasVoted[msg.sender], "This address has already voted.");
        euint8 choice = FHEVM.asEuint8(encryptedChoice);
        for (uint8 i = 0; i < candidates.length; i++) {
            euint32 isThisOption = FHEVM.eq(choice, FHEVM.trivialEncrypt_uint8(i));
            encryptedVotes[i] = FHEVM.add(encryptedVotes[i], isThisOption);
        }
        hasVoted[msg.sender] = true;
        emit VoteCasted(msg.sender);
    }

    function revealResult() public {
        require(msg.sender == owner, "Only the contract owner can reveal results.");
        require(block.timestamp >= votingEndTimestamp, "Voting has not ended yet.");
        require(!resultsRevealed, "Results have already been revealed.");
        for (uint8 i = 0; i < candidates.length; i++) {
            uint32 decryptedVoteCount = FHEVM.decrypt(encryptedVotes[i]);
            results.push(decryptedVoteCount);
        }
        resultsRevealed = true;
        emit ResultsRevealed(candidates, results);
    }

    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
