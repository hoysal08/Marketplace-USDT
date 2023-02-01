
# Marketplace Contract with USDT support

The repo contains 3 contracts
1. Marketplace Contract
2. Sample USDT Contract
3. Sample Price Oracle Contract

<br><br>
## Front Running Attack

Transactions take some time before they are mined. An attacker can watch the transaction pool and send a transaction, have it included in a block before the original transaction. This mechanism can be abused to re-order transactions to the attacker's advantage  
<br>
### Possible Solution :
### Commit-Reveal Schemes (Inspired by ERC-5732: Commit Interface)

We can Implement commit-reveal schemes in marketplace contract by, making users reserve the item they want to Buy which equates to a commit operations and to verify hash submitted when purchased.

The attacker will have front-run 3 transactions to achieve a meaning full attack here, which might not be economically profitable.

<br><br>

## Price Oracle Info
#####  Due to to absence of ETH/USDT oracle on testnet, I am using ETH/USD

- Network: Goerli
- Provider : ChainLink
- Aggregator: ETH/USD
- Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e

<br><br>
## Gas optimisation Considered
1. using external rather than public, for function declarations 
2. using indexed aurguments for events.
3. using delete, which will refunds 15,000 gas upto max of half of transaction fee.
4. keeping revert strings small as possible or using custom error if using compilers >0.8.4.
5. use multiple require statements rather than chaining condition using &&.  
6. use memory variable to save gas on access and modification over state variables.

<br><br>
## Work Flow

- We can List new Items by  ``` function addItem(
        uint256 _id,
        string memory _name,
        uint256 _price,
        uint256 _shippingPrice
    ) ``` , this will create new Items with unique Id's .
- We can update or add shipping Price for existing items using ```function addShippingPrices(uint256 _id, uint256 _shippingPrice)```
- We can Buy Items using the following order
   1. ``` function generatehash(uint256 id)```
   2. ``` function reserve(bytes32 hash)```
   3. ```function buyItem(uint256 id)```

<br><br>
## Contract Address
- [Marketplace - 0x64E4d633e709994e9D8ECB843E2056FAdBEdC096](https://goerli.etherscan.io/address/0x64E4d633e709994e9D8ECB843E2056FAdBEdC096)

- [USDT - 0x77925e831510A73E4E40e8C07becafBe8936D23f ](https://goerli.etherscan.io/address/0x77925e831510A73E4E40e8C07becafBe8936D23f#readContract)

- [Price Oracle - 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e](https://goerli.etherscan.io/address/0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e)

## Instructions 
#### You can run dependencies using  
```npm install```
#### You can compile contracts using 
```npm hardhat compile```
#### You can run tests using 
```npm hardhat test```
### You can deploy by 
```npm run scripts/deploy.js --network <n/w>```