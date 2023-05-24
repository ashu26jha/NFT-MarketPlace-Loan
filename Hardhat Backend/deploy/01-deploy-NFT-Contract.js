const { network, ethers } = require("hardhat");
const { networkConfig, developmentChains, RobotNftMintPrice, CatNftMintPrice } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify")
require("@nomiclabs/hardhat-etherscan"); 



module.exports = async  ({getNamedAccounts,deployments})=>{
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();
    const chainId = network.config.chainId;
    let waitConfirmations;
    if (!developmentChains.includes(network.name)){
        waitConfirmations = 5
    } 
    else{
        waitConfirmations = 1
    }
    const NftMarketPlace = await deploy ("NftMarketPlace",{
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitConfirmations,
    });

    const RobotNftContract = await deploy ("RobotNft",{
        from: deployer,
        args: [RobotNftMintPrice],
        log: true,
        waitConfirmations: 1,
    });

    const CatNftContract = await deploy ("CatNft",{
        from: deployer,
        args: [CatNftMintPrice],
        log: true,
        waitConfirmations: waitConfirmations,
    });

    

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(CatNftContract.address,[CatNftMintPrice]);
        await verify(RobotNftContract.address,[RobotNftMintPrice]);
        await verify(NftMarketPlace.address, []);

    }
    log("----------------------------------------------------")
}

module.exports.tags = ["all", "nft"]
