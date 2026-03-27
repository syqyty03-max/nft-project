# OmniDrop: Production-Ready ERC721A Collection on Base

High-performance, gas-optimized NFT Smart Contract engineered for large-scale drops on the Base L2 network.

## Core Architecture
- **ERC721A standard:** Massively reduces gas costs for batch minting.
- **Merkle Tree Whitelist:** Cryptographically secure presale verification with zero on-chain storage overhead.
- **Blind Mint & Reveal:** Secure placeholder metadata switching to actual metadata post-mint.
- **Custom Errors:** Eliminates standard string reverts to save deployment and execution gas.

## Setup & Deployment

   npm install

cp .env.example .env

npm run deploy:base

npx hardhat verify --network base_mainnet <DEPLOYED_ADDRESS> "ipfs://YOUR_HIDDEN_CID/hidden.json"
