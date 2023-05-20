const { network, ethers } = require("hardhat");
const { networkConfig, developmentChains, RobotNftMintPrice, CatNftMintPrice } = require("../helper-hardhat-config");
// const { verify } = require("../utils/verify")


module.exports = async  ({getNamedAccounts,deployments})=>{
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();
    const chainId = network.config.chainId;
    const waitBlockConfirmations = (networkConfig[chainId]).waitConfirmations;
    console.log("ethers.utils.parseEther(1).toString()")
    const RobotNftContract = await deploy ("RobotNft",{
        from: deployer,
        args: [RobotNftMintPrice],
        log: true,
        waitConfirmations: waitBlockConfirmations | 1 ,
    })

    const CatNftContract = await deploy ("CatNft",{
        from: deployer,
        args: [CatNftMintPrice],
        log: true,
        waitConfirmations: waitBlockConfirmations | 1 ,
    })


}
