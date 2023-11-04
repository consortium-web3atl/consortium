import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const {deployments} = hre;
	const {deploy} = deployments;
    console.log("oi");
	const [owner] = await hre.ethers.getSigners();

     //Replace with WETH on destination Chain
     const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

     //TODO: Replace with Timelock GovController on destination Chain
     const govController = "0xdead";

	await deploy('TokenVault', {
		from: owner.address,
		args: [],
		log: true,
		autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
	});
    
    // await deploy('LockManager_Timelock', {
	// 	from: owner.address,
	// 	args: [WETH],
	// 	log: true,
	// 	autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
	// });

    await deploy('MetadataHandler', {
		from: owner.address,
		args: [""],
		log: true,
		autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
	});

    

    console.log("finish");
};
export default func;
func.tags = ['SimpleERC20'];