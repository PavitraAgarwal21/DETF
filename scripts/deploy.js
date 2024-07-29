const hre = require("hardhat");

async function main() {
  let lockedAmount = 2 ; 
  let unlockTime = 1000000000000000; 
  const Create = await hre.ethers.deployContract("Lock" ,[unlockTime]);
  await Create.waitForDeployment();
  console.log("contract Address:", Create.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});