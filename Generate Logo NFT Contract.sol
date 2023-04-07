// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LogoGenerator is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    address public owner;
    uint256 public price;
    uint256 public maxSupply;
    uint256 public currentSupply;
    mapping(uint256 => bytes32) public tokenIdToHash;

    event LogoMinted(address indexed owner, uint256 indexed tokenId, bytes32 hash);

    constructor(uint256 _price, uint256 _maxSupply) ERC721("Business Logo", "BL") {
        owner = msg.sender;
        price = _price;
        maxSupply = _maxSupply;
        currentSupply = 0;
    }

    function generateLogo() public payable {
        require(msg.value >= price, "Insufficient payment");
        require(currentSupply < maxSupply, "Max supply reached");
        bytes32 hash = keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender));
        uint256 tokenId = _tokenIdTracker.current();
        _safeMint(msg.sender, tokenId);
        tokenIdToHash[tokenId] = hash;
        _tokenIdTracker.increment();
        currentSupply++;
        emit LogoMinted(msg.sender, tokenId, hash);
    }

    function withdraw() public {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }
}
