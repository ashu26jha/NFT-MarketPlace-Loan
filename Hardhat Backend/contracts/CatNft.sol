// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error CatNft__NotEnoughETH();
error CatNft__DoesNotExist();
error CatNft__AlreadyMinted();

contract CatNft is ERC721, ERC721URIStorage {
    
    uint256 private immutable i_mintFee;

    event mintedCatEvent (
        address indexed minter,
        uint256 indexed tokenId
    );
        
    constructor(uint256 _mintFee) ERC721("CatNft","CNT"){
        i_mintFee = _mintFee;
    }

    mapping(uint256 => uint8) minted;

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

    function safeMint(uint256 tokenId) payable external{

        if (msg.value < i_mintFee){
            revert CatNft__NotEnoughETH();
        }
        if (tokenId > 7){
            revert CatNft__DoesNotExist();
        }
        if(minted[tokenId]==1){
            revert CatNft__AlreadyMinted();
        }

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURIs[tokenId]);
        minted[tokenId] = 1;
        emit mintedCatEvent(msg.sender,tokenId);
    }

    function mintStatus(uint256 tokenId) public view returns(uint8){
        return minted[tokenId];
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

}
