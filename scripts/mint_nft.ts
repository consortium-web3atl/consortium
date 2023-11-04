import { ethers, artifacts } from "hardhat";
import {transactions} from "../broadcast/RevestV2_deployment.s.sol/421613/run-latest.json";
import { Controller, Controller__factory, IController } from "../typechain-types";
import { ControllerInterface } from "../typechain-types/src/Controller";

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

    const USDCAddrGoerliArbitrum = "0xfd064a18f3bf249cf1f87fc203e90d8f650f2d63";
    
    const tokenVaultAddr = "0xBd4DA114ac9117E131f101bB8eCd04dBA2aA52B4";
  const lockManagerTimelockAddr = "0xF26a375FB3907e994D74A868f9212e0168B422E0";
  const metadataHandlerAddr = "0x3988f7CFb7baF15b24a62CA3F4336180cF5C1EBe"; 
  const revest1155Addr = "0xB9b72065Da320380a19a914397B9f057a1d367fa";
  const revest721Addr = "0x5e55ceF07BB0ac38ca563f032eaBd780C00D5c4c"; 
  const fNFTHandlerAddr = "0xdb00767B46650135D2854BBd4cbd502e6E397E84";
  const controllerAddr = "0x1De7Ec43eebaA526D0cF71B048B6E01BD8cfd51A";
    
    // ToDo - Handle approvals
    const config = {
        handler: metadataHandlerAddr,
        asset: USDCAddrGoerliArbitrum,
        lockManager: lockManagerTimelockAddr,
        nonce: 0,
        fnftId: 1,
        maturityExtension: false
    } as IController.FNFTConfigStruct;
    const recipients = [addr1_address];
    const amount = 1;
    const result = await controllerContract.mintAddressLock("0xab", recipients, [amount], amount, config);
    console.log('result', result);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
