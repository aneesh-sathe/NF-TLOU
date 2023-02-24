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
        uint specialAttack; // EVERY 3rd ATTACK IS A SPECIAL ATTACK 

    }

    struct Bloater{
        string name;
        string imgURL;
        uint HP;
        uint maxHP;
        uint Attack; // 70% CHANCE THAT ATTACK WILL MISS DUE TO SLOW SPEED IN THE VIDEO GAME
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenID;

    avatarAttributes[] defaultAvatar;
    Bloater public bloater;

    mapping(uint256 => avatarAttributes) public nftHolderAttributes;
    mapping(address => uint256[]) public nftHolders;
    uint flag = 0;
    uint attackCount = 0;

    
    constructor(
        string[] memory avatarNames,
        string[] memory avatarURL,
        uint[] memory avatarHP,
        uint[] memory avatarBaseAttack,
        uint[] memory avatarSpcAttack,
        string memory bloaterName,
        string memory bloaterURL,
        uint bloaterHP,
        uint bloaterAttack
    ) ERC721("Fireflies", "FLY"){

        bloater = Bloater({
            name: bloaterName,
            imgURL: bloaterURL,
            HP: bloaterHP,
            maxHP: bloaterHP,
            Attack: bloaterAttack
        });

        console.log("done initialising %s w/ %s HP, %s Attack ", bloater.name, bloater.HP, bloater.Attack);

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

    function random(uint _div) internal returns(uint){
        flag++;
        return uint(keccak256(abi.encodePacked(block.timestamp, block.gaslimit, flag ))) % _div;

    }

    function attack() public {

        uint256 playerNFT = nftHolders[msg.sender][0]; // RETRIEVES FIRST NFT IN THE WALLET
        avatarAttributes storage player = nftHolderAttributes[playerNFT];
        console.log("\nplayer /w %s NFT has %s HP Left", player.name, player.HP);
        console.log("%s has %s HP Left", bloater.name, bloater.HP);


        require(bloater.HP > 0, "Bloater has no HP left!");
        require(player.HP > 0, "Player has no HP left!");

        if(bloater.HP < player.baseAttack){
            bloater.HP = 0;
            console.log("Bloater slayed by %s!", player.name);
        } else {
            attackCount++;
            if(attackCount % 3 == 0){
                console.log("Special Attack Activated!");
                bloater.HP = bloater.HP - player.specialAttack;
                console.log("%s attacked Bloater! Bloater HP: %s", player.name, bloater.HP);
            } else{
                bloater.HP = bloater.HP - player.baseAttack;
                console.log("%s attacked Bloater! Bloater HP: %s", player.name, bloater.HP);
            }
        }

        if(player.HP < bloater.Attack){
            player.HP = 0;
            console.log("Oh, No! %s got YEETED!", player.name);
            console.log("Try Minting another Character?");
        } else{
            if(random(10) > 3){
                console.log("Bloater Missed!");
            } else{
                player.HP = player.HP - bloater.Attack;  
                console.log("Bloater attacked %s! %s HP: %s", player.name, player.name, player.HP);
            }
            
        }



    }
}