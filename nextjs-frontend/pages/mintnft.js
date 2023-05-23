import Head from 'next/head';
import Navbar from "../components/Navbar";
import { useWeb3Contract } from "react-moralis";
import helper from "./helper";
import RobotNftABI from '../constants/RobotNft.json';
import CatNftABI from '../constants/CatNft.json';
import Link from 'next/link';

export default function mintnft(){
    let RobotNftAddress, CatNftAddress, chainID;
    [RobotNftAddress,CatNftAddress,chainID] = helper()
    return(
        <>
            <Navbar/>

        </>
    )
}
