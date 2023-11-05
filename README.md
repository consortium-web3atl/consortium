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
