import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const HIDDEN_URI = "ipfs://QmYourHiddenFolderCID/hidden.json";

  const OmniDrop = await ethers.getContractFactory("OmniDrop");
  const nft = await OmniDrop.deploy(HIDDEN_URI);

  await nft.waitForDeployment();
  const address = await nft.getAddress();

  console.log(`OmniDrop deployed to: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
