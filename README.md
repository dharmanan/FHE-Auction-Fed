# FHE-Auction-Fed
Secret voting on the blockchain

# FHE Voting DApp

This project is a full-stack confidential voting application using Fully Homomorphic Encryption (FHE) with Zama's Concrete SDK and Solidity smart contracts.

## Components

- **Backend:** Python FastAPI service for FHE encryption and blockchain interaction
- **Frontend:** React app for user voting interface
- **Smart Contract:** Solidity contract for secure, encrypted vote tallying

## Candidates
- Kevin Warsh
- Kevin Hassett
- Christopher Waller
- Michelle Bowman

## How it Works
1. User selects a candidate in the frontend.
2. The backend encrypts the vote using Zama's Concrete SDK.
3. The backend sends the encrypted vote to the smart contract on Ethereum.
4. The contract tallies encrypted votes securely.
5. Results are revealed by the contract owner after voting ends.

## Installation & Running

### 1. Smart Contract
- Compile and deploy `contract/FedChairVoting.sol` to your Ethereum-compatible network (e.g., local Hardhat, Anvil, or testnet).
- Save the contract ABI as `backend/FedChairVoting.json` and update the contract address in `backend/.env`.

### 2. Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # Edit with your contract address and node URL
uvicorn main:app --reload
```

### 3. Frontend
```bash
cd frontend
npm install
npm start
```

- Frontend runs on http://localhost:3000
- Backend runs on http://localhost:8000

### 4. Voting
- Open the frontend, select a candidate, and vote!
- Votes are encrypted and sent to the smart contract via the backend.
