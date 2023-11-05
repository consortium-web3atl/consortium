import { ethers, artifacts } from "hardhat";
import {deal} from "hardhat-deal";
import {transactions} from "../broadcast/RevestV2_deployment.s.sol/421613/run-latest.json";
import { Controller, Controller__factory, IController } from "../typechain-types";
import { ControllerInterface } from "../typechain-types/src/Controller";
const hre = require("hardhat");

async function main() {
  
    const [owner, addr1] = await ethers.getSigners();
    console.log("owner", owner.address, "addr1", addr1.address);
    
    const addr1_address = await addr1.getAddress();
    const controllerDeployment = transactions.find(x => x.contractName === "Controller")!;
    const controllerAddress = controllerDeployment.contractAddress;
    const controllerArtifact = artifacts.readArtifactSync("Controller");
    const controllerContract = await ethers.getContractAtFromArtifact(controllerArtifact, controllerAddress, owner);

    // const controllerContract = Controller__factory.connect(controllerAddress);
    console.log('controller deployed at', await controllerContract.getAddress());

    const USDCAddrGoerliArbitrum = "0x179522635726710dd7d2035a81d856de4aa7836c";
    
    const tokenVaultAddr = "0xBd4DA114ac9117E131f101bB8eCd04dBA2aA52B4";
  const lockManagerTimelockAddr = "0xF26a375FB3907e994D74A868f9212e0168B422E0";
  const metadataHandlerAddr = "0x3988f7CFb7baF15b24a62CA3F4336180cF5C1EBe"; 
  const revest1155Addr = "0xB9b72065Da320380a19a914397B9f057a1d367fa";
  const revest721Addr = "0x5e55ceF07BB0ac38ca563f032eaBd780C00D5c4c"; 
  const fNFTHandlerAddr = "0xdb00767B46650135D2854BBd4cbd502e6E397E84";
  const controllerAddr = "0x1De7Ec43eebaA526D0cF71B048B6E01BD8cfd51A";
  const cnftAddr = "0x26a5BE39521F8e70fEfe14dB40043De82B5B7784";
  const lockManagerAddressLock = "0x7543972Be5497AF54bab4fDe333Ffa53b5C52cF2";
    
//   const revest1155Contract = await ethers.getContractAtFromArtifact(artifacts.readArtifactSync("Revest_1155"), revest1155Addr);
   const revest721Contract = await ethers.getContractAtFromArtifact(artifacts.readArtifactSync("Revest_721"), revest721Addr);

    const usdcContract = await ethers.getContractAtFromArtifact(artifacts.readArtifactSync("IERC20"), USDCAddrGoerliArbitrum);

    console.log("balance owner", (await usdcContract.balanceOf(owner.address)).toString());

     await usdcContract.approve(controllerAddress, 100000);
     await usdcContract.approve(revest721Addr, 100000);

     // ToDo Fix deal
     //await deal(USDCAddrGoerliArbitrum, owner.address, 10_000_000);

    
    const config = {
        handler: cnftAddr,
        asset: USDCAddrGoerliArbitrum,
        lockManager: lockManagerAddressLock,
        nonce: 0,
        fnftId: 1,
        maturityExtension: false
    } as IController.FNFTConfigStruct;
    const recipients = [addr1_address];
    const amount = 3;
    
    console.log('here');
    const latestBlock = await hre.ethers.provider.getBlock("latest");
    //const result = await controllerContract.mintAddressLock("0xab", recipients, [1], //amount, config);
    const result = await revest721Contract.mintAddressLock("0xab", recipients, [1], amount, config);
    //const result = await controllerContract.mintTimeLock(latestBlock.timestamp + 1000, recipients, [1], amount, config);
    console.log('result', result, "result0", result[0],"result1", result[1]);
    
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
