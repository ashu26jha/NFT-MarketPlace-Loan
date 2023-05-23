const { ethers, network } = require("hardhat");
const fs = require("fs")
const FRONT_END_CONTRACT_FILE = '../nextjs-frontend/constants/networkMapping.json'; 
const RobotNft__ABI_LOCATION = '../nextjs-frontend/constants/RobotNft.json';
const CatNft__ABI_LOCATION = '../nextjs-frontend/constants/CatNft.json';
const NftMarketPlace__ABI_LOCATION = '../nextjs-frontend/constants/NftMarketPlace.json';

module.exports = async function ()  {
    if(process.env.UPDATE_FRONT_END){
        console.log("Updating front end....");
        await updateContractAddress();
        await updateAbi();
    }
}

async function updateAbi (){
    const RobotNft = await ethers.getContract("RobotNft");
    const CatNft = await ethers.getContract("CatNft");
    const NftMarketPlace = await ethers.getContract("NftMarketPlace");

    let RobotNftabi =[];
    RobotNftabi.push(RobotNft.interface.format(ethers.utils.FormatTypes.json));
    fs.writeFileSync(RobotNft__ABI_LOCATION, RobotNftabi.toString());

    let CatNftabi =[];
    CatNftabi.push(CatNft.interface.format(ethers.utils.FormatTypes.json));
    fs.writeFileSync(CatNft__ABI_LOCATION, CatNftabi.toString());

    let NftMarketPlaceabi =[];
    NftMarketPlaceabi.push(NftMarketPlace.interface.format(ethers.utils.FormatTypes.json));
    fs.writeFileSync(NftMarketPlace__ABI_LOCATION, NftMarketPlaceabi.toString());

}

async function updateContractAddress(){
    const RobotNft = await ethers.getContract("RobotNft");
    const CatNft = await ethers.getContract("CatNft");
    const NftMarketPlace = await ethers.getContract("NftMarketPlace");

    const chainId = network.config.chainId;
    const contractAddresses = JSON.parse(fs.readFileSync(FRONT_END_CONTRACT_FILE, "utf8"))

    if(chainId in contractAddresses){
        if(!contractAddresses[chainId].includes(RobotNft.address)){
            contractAddresses[chainId].push(RobotNft.address,CatNft.address,NftMarketPlace.address);
        }
    }
    else{
        contractAddresses[chainId]= [RobotNft.address,CatNft.address,NftMarketPlace.address];
    }
    console.log(chainId);
    fs.writeFileSync(FRONT_END_CONTRACT_FILE,JSON.stringify(contractAddresses),"utf-8");
}
module.exports.tags = ["all", "frontend"]
