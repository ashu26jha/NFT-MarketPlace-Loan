//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Robot/AI NFT implementation 

// OpenZeppelin Files
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Error reverts
error RobotNft__NotEnoughETH();
error RobotNft__DoesNotExist();
error RobotNft__AlreadyMinted();

contract RobotNft is ERC721{
    
    // Immutable variables
    uint256 private immutable i_mintFee;
    
    // List of token URIs
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
    
    // Mapping of minted NFTs
    // TokenID => Boolean (Minted or not)
    mapping(uint256 => uint8) minted;

    constructor(uint256 _mintFee) ERC721("Robot","RBT"){
        i_mintFee = _mintFee;
    }

    function mintNFT(uint256 tokenId) payable external{
        if (msg.value < i_mintFee){
            revert RobotNft__NotEnoughETH();
        }
        if (tokenId > 7){
            revert RobotNft__DoesNotExist();
        }
        if(minted[tokenId]==1){
            revert RobotNft__AlreadyMinted();
        }

        _safeMint(msg.sender,tokenId);
        minted[tokenId] = 1;
    }

    // MintStatus
    function mintStatus(uint256 tokenId) public view returns(uint8){
        return minted[tokenId];
    }

    function getTokenURI(uint256 tokenId)public view returns(string memory){
        return tokenURIs[tokenId];
    }

}
