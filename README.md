# PolyBets Core

## Contract Structure
* **BetToken.sol** - BET token contract
* **PolyBets.sol** - Betting Logic and Farming Pool contract
* **VRFv2Consumer.sol** - Chainlink VRF

## Contract Deployment
### Chainlink VRF Config
1. Get Network Config [here]("https://docs.chain.link/vrf/v2/direct-funding/supported-networks") and replace variables on `VRFv2Consumer.sol`
2. Create Subscription [here]("https://vrf.chain.link/")
3. Use `subscriptionId` on UI as constructor parameter for `VRFv2Consumer.sol`

### BET Token Contract Deploy
1. Replace total supply at line 10

    `_mint(msg.sender, totalSupply * 10**18);`
2. Deploy contract and get address
3. If `Testnet`, deploy additional token contract for BET-POLY LP.

### PolyBets Config
1. Replace follwing variables
    `54: address BET = use address of BET token;`

### PolyBets Deploy