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
            await expect ( RobotNftContract.safeMint(tokenID)).to.be.revertedWith("RobotNft__NotEnoughETH");
        })

        it("Does not mint NFT if tokenID is greater than 7 ", async function (){
            await expect ( RobotNftContract.safeMint(8,{value: RobotNftMintPrice}) ).to.be.revertedWith("RobotNft__DoesNotExist");
        })

        it("Does not allow to remint an NFT", async function(){
            const txReceipt = await RobotNftContract.safeMint(tokenID,{value: RobotNftMintPrice});
            txReceipt.wait(1);
            await expect (RobotNftContract.safeMint(tokenID, {value : RobotNftMintPrice})).to.be.revertedWith("RobotNft__AlreadyMinted");
            
            // Checks the mint status
            const mintStatus = await RobotNftContract.mintStatus(2);
            assert.equal(1,mintStatus);
            
            const tokenURI1 = await RobotNftContract.tokenURI(tokenID)
            assert.equal("bafkreihrq3flvy2gh6rzxzn43gxmtvir2iuhqgszfhtg2g2top2iid543i",tokenURI1);
        })

    });

    describe("Minting Cat NFT", async function(){
        const tokenID = 2;

        it("Does not mint NFT if not enough eth is send", async function (){
            await expect ( CatNftContract.safeMint(tokenID)).to.be.revertedWith("CatNft__NotEnoughETH");
        })

        it("Does not mint NFT if tokenID is greater than 7 ", async function (){
            await expect ( CatNftContract.safeMint(8,{value: CatNftMintPrice}) ).to.be.revertedWith("CatNft__DoesNotExist");
        })

        it("Does not allow to remint an NFT", async function(){
            const txReceipt = await CatNftContract.safeMint(tokenID,{value: CatNftMintPrice});
            txReceipt.wait(1);
            await expect (CatNftContract.safeMint(tokenID, {value : CatNftMintPrice})).to.be.revertedWith("CatNft__AlreadyMinted");
            
            // Checks the mint status
            const mintStatus = await CatNftContract.mintStatus(2);
            assert.equal(1,mintStatus);

            const tokenURI1 = await CatNftContract.tokenURI(tokenID)
            assert.equal("bafkreibmycdy5eklvwtwbls4kzwdhpul2xzivldtohptffj5owxwego62m",tokenURI1);
        })

    });

    // MARKETPLACE LOAN TESTS

    describe("NFT Marketplace loan tests", async function (){

        it("Only allows owner of NFT to list it", async function(){
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await expect (NftMarketPlaceContract.connect(account2).ListLoan(RobotNftContract.address,2,2,2)).to.be.revertedWith("NotOwner()")
        });
        
        it("Checks for event emiited after listing", async function (){
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,2);
            const getLoanDetails = await NftMarketPlaceContract.getLoanDetails(0);
            assert.equal(getLoanDetails.borrower,account1.address);
            assert.equal(getLoanDetails.tokenId.toString(),"2");
            // assert.equal(getLoanDetails[0])
        });

        // Add a test for Lender Deal

        it("Reverts if lender sends less amount", async function (){
            // Borrower listing:
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,2);
            // Trying to send less value than needed
            await expect (NftMarketPlaceContract.connect(account2).lenderDeal(0,3,{value: 1})).to.be.revertedWith("NftMarketPlace__BorrowerWantsMore()")
        });

        it("Finalise the deal",async function (){
            // Needs to check whether owner of the nft is the contract or not
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,2);
            await NftMarketPlaceContract.connect(account2).lenderDeal(0,3,{value: 2})
            // Any other account cannot finalise the deal
            await expect (NftMarketPlaceContract.connect(account2).finaliseDeal(0,account2.address)).to.be.revertedWith("Not borrower");
            await NftMarketPlaceContract.connect(account1).finaliseDeal(0,account2.address);
            const newNftOwner = await RobotNftContract.ownerOf(2);
            //Checks whether marketplace is owner of NFT or not
            assert.equal(newNftOwner,NftMarketPlaceContract.address);
        });

        it("Repayment in three installments", async function(){
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,"20000000000000000000");
            await NftMarketPlaceContract.connect(account2).lenderDeal(0,3,{value: 2});
            await NftMarketPlaceContract.connect(account1).finaliseDeal(0,account2.address);
            // Paying back
            await NftMarketPlaceContract.connect(account1).payback(0,{value: 1});
            await NftMarketPlaceContract.connect(account1).payback(0,{value: 1});
            await NftMarketPlaceContract.connect(account1).payback(0,{value: 1});
            // await NftMarketPlaceContract.connect(account1).payback(0,{value: 1});
            // Checking if NFT goes back to borrower
            assert.equal(await RobotNftContract.ownerOf(2),account1.address);
        });

        it("Fails to repay in time and NFT is confiscated", async function(){
            await RobotNftContract.safeMint(2,{value: RobotNftMintPrice});
            await RobotNftContract.approve(NftMarketPlaceContract.address,2);
            await NftMarketPlaceContract.ListLoan(RobotNftContract.address,2,2,"2");
            await NftMarketPlaceContract.connect(account2).lenderDeal(0,3,{value: 2});
            await NftMarketPlaceContract.connect(account1).finaliseDeal(0,account2.address);

            // Tries to steal the NFT

            await expect  (NftMarketPlaceContract.connect(account2).manualClaim(0)).to.be.revertedWith("Can't claim now")

            await NftMarketPlaceContract.connect(account1).payback(0,{value: 1});
            await ethers.provider.send('evm_increaseTime', [2]);
            await expect(NftMarketPlaceContract.connect(account1).payback(0,{value: 1})).to.be.revertedWith("Time is up");
            await expect(NftMarketPlaceContract.connect(account3).manualClaim(0)).to.be.revertedWith("NOT ALLOWED");
            await NftMarketPlaceContract.connect(account2).manualClaim(0)
            assert.equal(await RobotNftContract.ownerOf(2),account2.address);
        })


        // Add a test for payback
        
    })


})
