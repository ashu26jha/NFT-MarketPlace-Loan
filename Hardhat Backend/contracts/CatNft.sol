// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Error reverts
error CatNft__NotEnoughETH();
error CatNft__DoesNotExist();
error CatNft__AlreadyMinted();

contract CatNft is ERC721{
    
    // Immutable variables
    uint256 private immutable i_mintFee;
    
    // List of token URIs
    string [] private tokenURIs = [
        "bafkreiaidflzvyhguszit4kiid3lilzwihdpfx7jgad6enofaphyn7jdaa",
        "bafkreigi2ylq474d5qnw3txs6bmvpra3mg33lwrbft2ti73csb3xqbtivm",
        "bafkreibmycdy5eklvwtwbls4kzwdhpul2xzivldtohptffj5owxwego62m",
        "bafkreig3sifqmfin4omzo3weujrax6icqux3kftazpqhuss25dg5tbwjwi",
        "bafkreigvnflgpovgia7fgwotb5rx7lvlp4mekwqkrzzqsw2tigx4fjgije",
        "bafkreibui3vkbdn5r7ocyczru6nhnznljqcrhm7rc2nbh4ahpvtxpphisu",
        "bafkreigobgcjxo7oheetgsdqm54ujpscuurow363ik2ope25rzjalfpwum",
        "bafkreiepmk3wl5ns3266h2qcsvtohkl572hmm3i2khvvyja54orjddbqxu"
    ];
    
    // Mapping of minted NFTs
    // TokenID => Boolean (Minted or not)
    mapping(uint256 => bool) minted;

    constructor(uint256 _mintFee) ERC721("CatNft","CNT"){
        i_mintFee = _mintFee;
    }

    function mintNFT(uint256 tokenId) payable external{
        if (msg.value < i_mintFee){
            revert CatNft__NotEnoughETH();
        }
        if (tokenId > 7){
            revert CatNft__DoesNotExist();
        }
        if(minted[tokenId]==true){
            revert CatNft__AlreadyMinted();
        }

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURIs[tokenId]);
        minted[tokenId] = true;
    }

    // MintStatus
    function mintStatus(uint256 tokenId) public view returns(bool){
        return minted[tokenId];
    }

    function getTokenURI(uint256 tokenId)public view returns(string memory){
        return tokenURIs[tokenId];
    }

}
