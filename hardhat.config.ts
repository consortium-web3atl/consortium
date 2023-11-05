import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-preprocessor";
import "@nomicfoundation/hardhat-foundry";
import "hardhat-deal";
import "hardhat-deploy";
import {config as config_dotenv} from "dotenv";
config_dotenv();

import fs from "fs"

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://localhost:8545",
      accounts: [process.env.PRIVATE_KEY!, process.env.PRIVATE_KEY2!]
    }
  },
  // preprocess: {
  //   eachLine: (hre) => ({
  //     transform: (line: string) => {
  //       if (line.match(/^\s*import /i)) {
  //         for (const [from, to] of getRemappings()) {
  //           if (line.includes(from)) {
  //             line = line.replace(from, to);
  //             break;
  //           }
  //         }
  //       }
  //       return line;
  //     },
  //   }),
  // },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
  },
};

export default config;
