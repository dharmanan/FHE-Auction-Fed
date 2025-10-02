import React, { useState } from "react";
import { ethers } from "ethers";

const candidates = [
  "Kevin Warsh",
  "Kevin Hassett",
  "Christopher Waller",
  "Michelle Bowman"
];

function App() {
  const [selected, setSelected] = useState(null);
  const [status, setStatus] = useState("");
  const [wallet, setWallet] = useState("");

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setWallet(accounts[0]);
        setStatus("Wallet connected: " + accounts[0]);
      } catch (e) {
        setStatus("Wallet connection failed");
      }
    } else {
      setStatus("MetaMask not found!");
    }
  };

  const handleVote = async () => {
    if (selected === null) return;
    setStatus("Submitting vote...");
    try {
      const res = await fetch("/api/vote", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ vote_index: selected, wallet })
      });
      const data = await res.json();
      if (data.status === "success") {
        setStatus("Vote submitted! Tx: " + data.tx_hash);
      } else {
        setStatus("Error: " + (data.message || "Unknown error"));
      }
    } catch (e) {
      setStatus("Error: " + e.message);
    }
  };

  return (
    <div style={{ maxWidth: 400, margin: "2rem auto", fontFamily: "sans-serif" }}>
      <h2>Federal Reserve Chair Voting</h2>
      <button onClick={connectWallet} style={{ marginBottom: 20 }}>
        {wallet ? "Wallet Connected" : "Connect Wallet"}
      </button>
      <div style={{ marginBottom: 10 }}>{wallet && ("Connected: " + wallet)}</div>
      <ul>
        {candidates.map((name, idx) => (
          <li key={idx}>
            <label>
              <input
                type="radio"
                name="candidate"
                value={idx}
                checked={selected === idx}
                onChange={() => setSelected(idx)}
                disabled={!wallet}
              />
              {" "}{name}
            </label>
          </li>
        ))}
      </ul>
      <button onClick={handleVote} disabled={selected === null || !wallet}>
        Vote
      </button>
      <div style={{ marginTop: 20, color: "#333" }}>{status}</div>
    </div>
  );
}

export default App;
