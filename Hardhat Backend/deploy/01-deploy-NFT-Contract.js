const { network, ethers } = require("hardhat");
const { networkConfig, developmentChains, RobotNftMintPrice, CatNftMintPrice } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify")
require("@nomiclabs/hardhat-etherscan"); 



module.exports = async  ({getNamedAccounts,deployments})=>{
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();
    const chainId = network.config.chainId;
    const waitBlockConfirmations = (networkConfig[chainId]).waitConfirmations;

    const NftMarketPlace = await deploy ("NftMarketPlace",{
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 5,
    });

    const RobotNftContract = await deploy ("RobotNft",{
        from: deployer,
        args: [RobotNftMintPrice],
        log: true,
        waitConfirmations: waitBlockConfirmations | 1 ,
    });

    const CatNftContract = await deploy ("CatNft",{
        from: deployer,
        args: [CatNftMintPrice],
        log: true,
        waitConfirmations: waitBlockConfirmations | 1 ,
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
