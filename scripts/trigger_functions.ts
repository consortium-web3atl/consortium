import { ethers, artifacts } from "hardhat";
import {deal} from "hardhat-deal";
import {transactions} from "../broadcast/RevestV2_deployment.s.sol/421613/run-latest.json";
import { Controller, Controller__factory, IController } from "../typechain-types";
import { ControllerInterface } from "../typechain-types/src/Controller";
const hre = require("hardhat");

async function main() {
  
  /*
  ToDo
  - call getPseudoRandomNumber and make sure you get a value back
  - 1 create a pool
  - 2 enterPool
  - 3 payInstallment
  - 4 call epochLottery
  */
    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
