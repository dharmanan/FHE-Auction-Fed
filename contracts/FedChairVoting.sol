// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Zama's FHE library to handle encrypted data types and operations.
import "fhevm/lib/fhevm.sol";

contract FedChairVoting {
    // An array to store the names of the candidates.
    string[] public candidates;

    // Mapping from a candidate's index to their encrypted vote total.
    mapping(uint8 => euint32) public encryptedVotes;

    // State variables for managing the poll.
    address public owner;
    uint256 public votingEndTimestamp;
    bool public resultsRevealed;

    // Mapping to ensure each address can only vote once.
    mapping(address => bool) public hasVoted;

    // This array will store the final decrypted results.
    uint32[] public results;

    // Events to log key actions on the blockchain.
    event VoteCasted(address indexed voter);
    event ResultsRevealed(string[] finalCandidates, uint32[] finalResults);

    // The constructor initializes the poll with a list of candidates and a duration.
    constructor(string[] memory _candidateNames, uint _votingDurationInSeconds) {
        owner = msg.sender;
        candidates = _candidateNames;
        votingEndTimestamp = block.timestamp + _votingDurationInSeconds;

        // Initialize an encrypted counter (as encrypted zero) for each candidate.
        for (uint8 i = 0; i < candidates.length; i++) {
            encryptedVotes[i] = euint32(0);
        }
    }

    /**
     * @dev Allows a user to cast an encrypted vote.
     * @param encryptedChoice The user's choice, encrypted on the client-side.
     */
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

    /**
     * @dev Allows the owner to decrypt and reveal the final results after the poll has ended.
     */
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

    /**
     * @dev A view function to easily retrieve the list of candidates.
     */
    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
