# Consortium

## How to deploy Revest contracts using Foundry

0 - Install dependencies (we use Foundry-only dependencies, Hardhat used only for scripting)
    ```
    forge install OpenZeppelin/openzeppelin-contracts@f347b410cf6aeeaaf5197e1fece139c793c03b2b --no-commit
    forge install
    ```

0b - Fill values on .env.local and rename it to .env

1 - Start local fork of Arbitrum Goerli (since we need CREATE3Factory contract, deployed at 0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1 on Arbitrum's Goerli but NOT Sepolia)
    - Set RPC_URL on .env
    ```
    source .env
    anvil --fork-url $RPC_URL
    ```
2 - Trigger deploy script of Revest contracts (in a new terminal)
    ```
    forge script script/RevestV2_deployment.s.sol --broadcast --tc RevestV2_deployment --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --names -vvvv > deployment_logs.txt
    ```

    Note that only the first time the deployment script above runs is successful. Additional executions lead to errors, since we try to deploy contracts onto same address due to CREATE3 being used.


3 - Execute `mintAddressLock` from Revest721
    This method locks a given `amount` of tokens into a TokenVault and transfers them into a SmartWallet, unique to each user.
    ```
    npx hardhat run scripts/mint_nft.ts --network localhost
    ```

### Getting started


```
# Terminal 1:
source .env
anvil --fork-url $RPC_URL  
```

```
# Terminal 2
forge script script/RevestV2_deployment.s.sol --broadcast --tc RevestV2_deployment --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --names -vvvv > deployment_logs.txt
npx hardhat run scripts/mint_nft.ts --network localhost
```

```
# Browser
-> See latest transaction for token transfer to become visible
```

## Deployed contract addresses on Arbitrum Goerli

  
  - Token Vault: 0x543EF074507F9E96c1c72b7c2E48F784352Bf3D7: 
  - Lock Manager Timelock: 0x6E81CBBBCb381f78f913dCa330f08Fd3d58C27D1: 
  - Metadata Handler: 0xcd3B8F0d62C85e89f4e6E0CC661dF23B51A81094: 
  - Revest 1155: 0x34797cFe2E2c056550D84B06D5F0553299d34622: 
  - Revest 721: 0xcD230f84d05F6098501Ac2672893989DDc4f1356: 
  - FNFT Handler: 0xc54C9C72Ad6c5381b857f6e8e778ea859572387c: 
  - Consortio nft: 0xC2e6F075540f33bE85b9638C7e4230039933C8c6
  - Lock manager address lock: 0xC7e9702fC3F6306a405A34839e8995F0eB03Bc27
 - Consortio 0x301C591609962C26F75F838b912D3ea70CF64E52