# Consortium

## How to deploy Revest contracts using Foundry

0 - Install dependencies
    ```
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
    forge script script/RevestV2_deployment.s.sol --broadcast --tc RevestV2_deployment -vvvvv --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY
    ```

    Note that only the first time the deployment script above runs is successful. Additional executions lead to errors (at least in my local setup)

