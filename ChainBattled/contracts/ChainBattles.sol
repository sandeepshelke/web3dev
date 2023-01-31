// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct skills {
        uint256 life;
        uint256 level;
        uint256 speed;
        uint256 strength;
    }

    mapping(uint256 => skills) public tokenIdToLevels;
    constructor() ERC721 ("Chain Battles", "CBTLS") {
    }

    function generateCharacter(uint256 tokenId) public view returns(string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",getLife(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strenth: ",getStrength(tokenId),'</text>',
            '</svg>'
        );
        return string(abi.encodePacked("data:image/svg+xml;base64,",Base64.encode(svg)));
    }

    function getLife(uint256 tokenId) public view returns(string memory) {
        return tokenIdToLevels[tokenId].life.toString();
    }

    function getLevels(uint256 tokenId) public view returns(string memory) {
        return tokenIdToLevels[tokenId].level.toString();
    }

    function getSpeed(uint256 tokenId) public view returns(string memory) {
        return tokenIdToLevels[tokenId].speed.toString();
    }

    function getStrength(uint256 tokenId) public view returns(string memory) {
        return tokenIdToLevels[tokenId].strength.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns(string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function mint() public {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
        skills memory skill;
        skill.level = random(30);
        skill.life = random(100);
        skill.speed = random(100);
        skill.strength = random(100);
        tokenIdToLevels[tokenId] = skill;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train");
        skills memory skill = tokenIdToLevels[tokenId];
        skill.level = skill.level + 1;
        skill.life =  random(100);
        skill.speed = random(100);
        skill.strength = random(100);
        tokenIdToLevels[tokenId] = skill;
        _setTokenURI(tokenId, getTokenURI((tokenId)));
    }

    function random(uint number) public view returns(uint) {
        // https://blog.finxter.com/how-to-generate-random-numbers-in-solidity/
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,
        msg.sender))) % number;
    }
}
