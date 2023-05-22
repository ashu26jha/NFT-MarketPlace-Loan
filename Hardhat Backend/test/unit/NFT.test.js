const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains, RobotNftMintPrice, CatNftMintPrice } = require("../../helper-hardhat-config")

//writing the test code from here..  ethers.utils.parseEther(1).toString()

!developmentChains.includes(network.name) ? describe.skip : describe("Basic NFT Unit Tests", function () {
    let RobotNftContract, CatNftContract, NftMarketPlaceContract,accounts, account1, account2, account3;

    beforeEach(async function(){
        await deployments.fixture("all");
        RobotNftContract = await ethers.getContract("RobotNft");
        CatNftContract = await ethers.getContract("CatNft");
        NftMarketPlaceContract = await ethers.getContract("NftMarketPlace")
        accounts = await ethers.getSigners();
        account1 = accounts[0];
        account2 = accounts[1];
        account3 = accounts[2];
    })

    // Minting an nft with tokenID 2

    describe("Minting Robot NFT", async function(){
        const tokenID = 2;

        it("Does not mint NFT if not enough eth is send", async function (){
            await expect ( RobotNftContract.mintNFT(tokenID)).to.be.revertedWith("RobotNft__NotEnoughETH");
        })

        it("Does not mint NFT if tokenID is greater than 7 ", async function (){
            await expect ( RobotNftContract.mintNFT(8,{value: RobotNftMintPrice}) ).to.be.revertedWith("RobotNft__DoesNotExist");
        })

        it("Does not allow to remint an NFT", async function(){
            const txReceipt = await RobotNftContract.mintNFT(tokenID,{value: RobotNftMintPrice});
            txReceipt.wait(1);
            await expect (RobotNftContract.mintNFT(tokenID, {value : RobotNftMintPrice})).to.be.revertedWith("RobotNft__AlreadyMinted");
            
            // Checks the mint status
            const mintStatus = await RobotNftContract.mintStatus(2);
            assert.equal(1,mintStatus);
            
            const tokenURI1 = await RobotNftContract.getTokenURI(tokenID)
            assert.equal("bafkreihrq3flvy2gh6rzxzn43gxmtvir2iuhqgszfhtg2g2top2iid543i",tokenURI1);
        })

    });

    describe("Minting Cat NFT", async function(){
        const tokenID = 2;

        it("Does not mint NFT if not enough eth is send", async function (){
            await expect ( CatNftContract.mintNFT(tokenID)).to.be.revertedWith("CatNft__NotEnoughETH");
        })

        it("Does not mint NFT if tokenID is greater than 7 ", async function (){
            await expect ( CatNftContract.mintNFT(8,{value: CatNftMintPrice}) ).to.be.revertedWith("CatNft__DoesNotExist");
        })

        it("Does not allow to remint an NFT", async function(){
            const txReceipt = await CatNftContract.mintNFT(tokenID,{value: CatNftMintPrice});
            txReceipt.wait(1);
            await expect (CatNftContract.mintNFT(tokenID, {value : CatNftMintPrice})).to.be.revertedWith("CatNft__AlreadyMinted");
            
            // Checks the mint status
            const mintStatus = await CatNftContract.mintStatus(2);
            assert.equal(1,mintStatus);

            const tokenURI1 = await CatNftContract.getTokenURI(tokenID)
            assert.equal("bafkreibmycdy5eklvwtwbls4kzwdhpul2xzivldtohptffj5owxwego62m",tokenURI1);
        })

    });

    // MARKETPLACE TESTS

    describe("NFT Marketplace tests", async function (){

        it("Only allows owner of NFT to list it", async function(){
            await RobotNftContract.mintNFT(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await expect (NftMarketPlaceContract.connect(account2).ListLoan(RobotNftContract.address,2,2,2)).to.be.revertedWith("NotOwner()")
        });

        it("Checks for event emiited after listing", async function (){
            await RobotNftContract.mintNFT(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,2);
            const getLoanDetails = await NftMarketPlaceContract.getLoanDetails(0);
            assert.equal(getLoanDetails.borrower,account1.address);
            assert.equal(getLoanDetails.tokenId.toString(),"2");
            console.log(getLoanDetails);
            // assert.equal(getLoanDetails[0])
        })
        
    })


})
