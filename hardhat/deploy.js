const hre = require("hardhat");

async function main() {
  const candidates = [
    "Kevin Warsh",
    "Kevin Hassett",
    "Christopher Waller",
    "Michelle Bowman"
  ];
  const votingDuration = 86400; // 1 day in seconds

  const FedChairVoting = await hre.ethers.getContractFactory("FedChairVoting");
  const contract = await FedChairVoting.deploy(candidates, votingDuration);
  await contract.deployed();
  console.log("FedChairVoting deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
