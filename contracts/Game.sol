//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

contract Game is ERC721{
    
    struct avatarAttributes{
        uint avatarIndex;
        string name;
        string imgURL;
        uint HP;
        uint maxHP;
        uint baseAttack;
        uint specialAttack;

    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenID;

    avatarAttributes[] defaultAvatar;

    mapping(uint256 => avatarAttributes) public nftHolderAttributes;
    mapping(address => uint256[]) public nftHolders;
    
    constructor(
        string[] memory avatarNames,
        string[] memory avatarURL,
        uint[] memory avatarHP,
        uint[] memory avatarBaseAttack,
        uint[] memory avatarSpcAttack
    ) ERC721("Fireflies", "FLY"){
        for(uint i = 0; i< avatarNames.length; i++){
            defaultAvatar.push(avatarAttributes({
                avatarIndex : i, 
                name : avatarNames[i],
                imgURL : avatarURL[i],
                HP : avatarHP[i],
                maxHP : avatarHP[i],
                baseAttack : avatarBaseAttack[i],
                specialAttack : avatarSpcAttack[i]
            }));

            avatarAttributes memory avt = defaultAvatar[i];
            console.log("done initialising %s w/ %s HP %s BA", avt.name, avt.HP, avt.baseAttack);

        }

        _tokenID.increment();
    }

    function mintNFT(uint _index) external {
        uint256 nftID = _tokenID.current();
        _safeMint(msg.sender, nftID);

        nftHolderAttributes[nftID] = avatarAttributes({
            avatarIndex : _index,
            name : defaultAvatar[_index].name,
            imgURL : defaultAvatar[_index].imgURL,
            HP : defaultAvatar[_index].HP, 
            maxHP: defaultAvatar[_index].maxHP,
            baseAttack : defaultAvatar[_index].baseAttack,
            specialAttack : defaultAvatar[_index].specialAttack
        });
        
        console.log("Minted NFT w/ tokenId %s and characterIndex %s", nftID, _index);
        nftHolders[msg.sender].push(nftID);
        _tokenID.increment();
    }

    function tokenURI(uint256 _tokenID) public view override returns(string memory){
        avatarAttributes memory avt = nftHolderAttributes[_tokenID];

        string memory strHP = Strings.toString(avt.HP);
        string memory strMaxHP = Strings.toString(avt.maxHP);
        string memory strBA = Strings.toString(avt.baseAttack);
        string memory strSA = Strings.toString(avt.specialAttack);

        string memory JSON = Base64.encode(
            abi.encodePacked(
        '{"name": "',
        avt.name,
        ' -- NFT #: ',
        Strings.toString(_tokenID),
        '", "description": "The Last of Us based NFT. Defeat the Bloater!", "image": "',
        avt.imgURL,
        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHP,', "maxValue":',strMaxHP,'}, { "trait_type": "Attack Damage", "baseAttack": ',
        strBA,', "specialAttack":',strSA,'} ]}'
        )
    );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", JSON)
        );

        return output;
    }
}