const { assert } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

//writing the test code from here..

!developmentChains.includes(network.name) ? describe.skip : describe("Basic NFT Unit Tests", function () {
    let CatNftContract, RobotNftContract;
    
})
