import contractAddresses from '../constants/networkMapping.json';
import { useMoralis } from "react-moralis";

export default function helper(){

    const { chainId: chainIdHex } = useMoralis();
    let RobotNftAddress, CatNftAddress, chainID, chainIDString;
    if(chainIdHex){
        chainIDString = chainIdHex.toString();
        chainID = parseInt(chainIdHex)
        RobotNftAddress = contractAddresses[chainID][0];
        CatNftAddress = contractAddresses[chainID][1];
    }
    return [RobotNftAddress,CatNftAddress,chainID];
}

