import Head from 'next/head';
import Navbar from "../components/Navbar";
import { useWeb3Contract } from "react-moralis";
import {RobotNftAddress,CatNftAddress,chainID}from "./helper";
import RobotNftABI from '../constants/RobotNft.json';
import CatNftABI from '../constants/CatNft.json';
import Link from 'next/link';

export default function mintnft(){

    return(
        <>
            <Navbar/>

        </>
    )
}
