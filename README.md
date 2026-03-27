# OmniDrop: Production-Ready ERC721A Collection on Base

High-performance, gas-optimized NFT Smart Contract engineered for large-scale drops on the Base L2 network.

## Core Architecture
- **ERC721A standard:** Massively reduces gas costs for batch minting.
- **Merkle Tree Whitelist:** Cryptographically secure presale verification with zero on-chain storage overhead.
- **Blind Mint & Reveal:** Secure placeholder metadata switching to actual metadata post-mint.
- **Custom Errors:** Eliminates standard string reverts to save deployment and execution gas.

## Setup & Deployment

1. **Install Dependencies**
   ```bash
   npm install
   2.  Environment Configuration

cp .env.example .env
3. Deploy to Base Mainnet
Update HIDDEN_URI in scripts/deploy.ts before executing:

npm run deploy:base
4. Verify Contract


npx hardhat verify --network base_mainnet <DEPLOYED_ADDRESS> "ipfs://YOUR_HIDDEN_CID/hidden.json"

Operational Flow

Deploy contract with Placeholder URI.

Generate Merkle Root off-chain and call setMerkleRoot.

Call toggleWhitelistSale to open presale.

Call togglePublicSale to open public sale.

Upload actual images/JSONs to IPFS.

Call reveal(ipfs://YOUR_ACTUAL_CID/) to update all metadata simultaneously.

Call withdraw() to transfer ETH to the deployer wallet.
