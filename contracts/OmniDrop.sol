// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OmniDrop is ERC721A, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_MINT_PER_TX = 10;
    uint256 public constant PUBLIC_PRICE = 0.01 ether;
    uint256 public constant WL_PRICE = 0.005 ether;

    string private baseTokenURI;
    string private hiddenTokenURI;
    
    bytes32 public merkleRoot;
    
    bool public isPublicSaleActive;
    bool public isWhitelistSaleActive;
    bool public isRevealed;

    mapping(address => uint256) public whitelistClaimed;

    error SaleNotActive();
    error ExceedsMaxSupply();
    error ExceedsMaxMint();
    error InsufficientFunds();
    error InvalidProof();
    error ExceedsWhitelistLimit();
    error WithdrawFailed();

    constructor(string memory _hiddenURI) ERC721A("OmniDrop Base", "OMNI") Ownable(msg.sender) {
        hiddenTokenURI = _hiddenURI;
    }

    function publicMint(uint256 quantity) external payable nonReentrant {
        if (!isPublicSaleActive) revert SaleNotActive();
        if (_totalMinted() + quantity > MAX_SUPPLY) revert ExceedsMaxSupply();
        if (quantity > MAX_MINT_PER_TX) revert ExceedsMaxMint();
        if (msg.value < PUBLIC_PRICE * quantity) revert InsufficientFunds();

        _safeMint(msg.sender, quantity);
    }

    function whitelistMint(uint256 quantity, uint256 maxAllowance, bytes32[] calldata proof) external payable nonReentrant {
        if (!isWhitelistSaleActive) revert SaleNotActive();
        if (_totalMinted() + quantity > MAX_SUPPLY) revert ExceedsMaxSupply();
        if (whitelistClaimed[msg.sender] + quantity > maxAllowance) revert ExceedsWhitelistLimit();
        if (msg.value < WL_PRICE * quantity) revert InsufficientFunds();

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, maxAllowance))));
        if (!MerkleProof.verify(proof, merkleRoot, leaf)) revert InvalidProof();

        whitelistClaimed[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        if (!isRevealed) {
            return hiddenTokenURI;
        }

        return bytes(baseTokenURI).length > 0 
            ? string(abi.encodePacked(baseTokenURI, tokenId.toString(), ".json")) 
            : "";
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function togglePublicSale() external onlyOwner {
        isPublicSaleActive = !isPublicSaleActive;
    }

    function toggleWhitelistSale() external onlyOwner {
        isWhitelistSaleActive = !isWhitelistSaleActive;
    }

    function reveal(string calldata _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
        isRevealed = true;
    }

    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function setHiddenURI(string calldata _hiddenURI) external onlyOwner {
        hiddenTokenURI = _hiddenURI;
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        if (!success) revert WithdrawFailed();
    }
}
