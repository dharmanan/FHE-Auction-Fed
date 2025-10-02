from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from web3 import Web3
from concrete.fhe import Configuration, fhe
import json
import os

app = FastAPI()

# Allow CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Blockchain and FHE Setup ---

w3 = Web3(Web3.HTTPProvider(os.getenv("ETH_NODE_URL", "http://127.0.0.1:8545")))
from web3.middleware import construct_sign_and_send_raw_middleware
private_key = os.getenv("PRIVATE_KEY")
if not private_key:
    raise Exception("PRIVATE_KEY not set in environment variables")
account = w3.eth.account.from_key(private_key)
w3.middleware_onion.add(construct_sign_and_send_raw_middleware(account))
w3.eth.default_account = account.address
contract_address = os.getenv("CONTRACT_ADDRESS", "0x...")

with open("FedChairVoting.json") as f:
    abi = json.load(f)["abi"]
contract = w3.eth.contract(address=contract_address, abi=abi)

candidates = [
    "Kevin Warsh",
    "Kevin Hassett",
    "Christopher Waller",
    "Michelle Bowman"
]

config = Configuration.from_specs({
    "vote_index": {"shape": (), "bounds": [0, 3], "is_encrypted": True}
})

@fhe.function(config)
def encrypt_vote(vote_index):
    return vote_index

compiler = encrypt_vote.compile()

@app.get("/candidates")
def get_candidates():
    return {"candidates": candidates}

@app.post("/vote")
async def vote(request: Request):
    data = await request.json()
    vote_index = data["vote_index"]
    encrypted_vote_args = compiler.encrypt(vote_index)
    encrypted_vote_bytes = compiler.serialize_encrypted_arguments(encrypted_vote_args)
    try:
        tx_hash = contract.functions.vote(encrypted_vote_bytes).transact()
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        return {"status": "success", "tx_hash": receipt.transactionHash.hex()}
    except Exception as e:
        return {"status": "error", "message": str(e)}
