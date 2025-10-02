# FHE Fed Chair Voting Backend

## Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Copy `.env.example` to `.env` and fill in your Ethereum node URL and contract address.
3. Place your compiled contract ABI as `FedChairVoting.json` in this directory.
4. Run the backend:
   ```bash
   uvicorn main:app --reload
   ```

## Endpoints
- `GET /candidates` — List candidates
- `POST /vote` — Submit a vote (expects `{ "vote_index": <int> }`)
