// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error RobotNft__NotEnoughETH();
error RobotNft__DoesNotExist();
error RobotNft__AlreadyMinted();

contract RobotNft is ERC721, ERC721URIStorage {

    uint256 private immutable i_mintFee;

    event mintedRobotEvent (
        address indexed minter,
        uint256 indexed tokenId
    );

    constructor(uint256 _mintFee) ERC721("Robot", "RBT") {
        i_mintFee = _mintFee;
    }

    mapping(uint256 => uint8) minted;

    string [] private tokenURIs = [
        "bafkreid4u3zcjdnnognsqfq2n5xzbub4ear4pxvadpjyvcfamkyn7xnh5y",
        "bafkreibho65hloym3fwcvdgluzgnxznhqb6kjbxd444oocuk7dtalf2p5a",
        "bafkreihrq3flvy2gh6rzxzn43gxmtvir2iuhqgszfhtg2g2top2iid543i",
        "bafkreihxnuuu4ueme77isilcwaqy7fndzk6kyxpo2khxma4ni6fkjvh7va",
        "bafkreihdhj7u4ecyq7dchp7fl2b7fcp4ggddlcuhqnt7y35fcpj4zt5dqm",
        "bafkreihirsrq2obrvpggor33ifm4enw6msnzspiokm7d7gndwgmuo6lqiq",
        "bafkreiget4ew6h4ligxw7xn6undimoj5t6vq3nuo34smmznrekitxa7rte",
        "bafkreigd6oulrbbdwyfn7wrjusfrid4dktbqd3cpgngmi5eopkbxvwhgnu"
    ];

    function safeMint(uint256 tokenId) public payable {

        if (msg.value < i_mintFee){
            revert RobotNft__NotEnoughETH();
        }
        if (tokenId > 7){
            revert RobotNft__DoesNotExist();
        }
        if(minted[tokenId]==1){
            revert RobotNft__AlreadyMinted();
        }

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURIs[tokenId]);
        minted[tokenId] = 1;
        emit mintedRobotEvent(msg.sender,tokenId);
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
