# Shylock Finance

## 1. Introduction

Shylock Finance is an innovative DeFi project designed to facilitate **cross-chain lending and borrowing**. At its core, it leverages the fundamental system of the **Compound Protocol** but stands out with its unique feature: an **under-collateralized loan** system.

This groundbreaking approach allows users to borrow amounts exceeding their collateral value. This is made possible through a comprehensive credit score system, DAO membership, and enhanced KYC procedures using DID technology, ensuring both security and accessibility.

**What is Shylock?**

<a href="https://www.metmuseum.org/art/collection/search/400327">
    <img src="assets/shylock.png" alt='Shylock (from "Twelve Characters from Shakespeare - John Hamilton Mortimer")' width="50%" height="50%">
</a>

The name **"Shylock"** is inspired by a character from William Shakespeare's "The Merchant of Venice." Known as a stringent moneylender, Shylock's character is synonymous with strict lending terms. In contrast, Shylock Finance reinterprets this concept for the DeFi world, focusing on innovative and flexible lending solutions. While drawing inspiration from Shylock’s adherence to strict principles, our project diverges by promoting a more equitable and accessible financial ecosystem.

### 1.1. Inspiration

Why can't we get credit in the web3 world? Unsecured loans, like traditional credit, seem too risky on the Web3. We thought that our activities, efforts and reputation on Dao could act as credit. So we came up with a low-collateralized loan that uses Dao's activities as credit and is jointly guaranteed by Dao and the protocol. 

From a user's perspective, it would be a very powerful welfare benefit for Dao, as it would be the only low-collateralized loan they would have to take care of urgent needs.

For Dao, it's a way to reward loyal contributors without minting new tokens. Not only does this satisfy both users and Dao, but it also creates a virtuous cycle as the harder an individual works, the more collateral they can back.

From an LP perspective, the protocol is also very attractive. Since the interest rate is higher than normal due to the low collateral nature of the loan, LPs will see it as a lending protocol where they can get high returns with a little bit of risk. As the liquidity increases, the amount of money available to users and Dao will also increase, so We think this is also a virtuous cycle that will lead to explosive growth.

Ultimately, we want to be the first step in a web3 where activities and positions on Dao will be seen as a profession, where we will be able to get credit for income and jobs on web2.

## 2. Project Overview

### 2.1. Architecture

![Shylock Finance Architecture Diagram](assets/ShylockFinance-Architecture.png)

### 2.2. Tech Stack

- **Frontend**: Next.js, Ethers.js
- **Backend**: Node.js, Express
- **Smart Contract**: Solidity, Foundry
- **Blockchain**: Avalanche C-Chain(Fuji), Ethereum(Sepolia), Polygon(Mumbai)
- **Cross-chain Messaging**: [CCIP(Cross-chain Interoperability Protocol)](https://chain.link/cross-chain)
- **Automated Liquidation**: [Chainlink Automation](https://chain.link/automation)
- **DAO Contribution Tracking**: [Chainlink Functions](https://chain.link/functions)
- **Price Oracle**: [Chainlink Data Feeds](https://data.chain.link/)
- **DID**: [Polygon ID](https://polygonid.com/)

## 3. How It Works

### 3.1. Liquidity Pool

The liquidity pool is a pool of funds that can be borrowed or lent by users. The pool is composed of funds from users and DAO's reserves.

### 3.2. shToken

shToken is a token that represents the amount of funds a user has deposited into the liquidity pool. It inherites the cToken in Compound Protocol. shTokens are minted when a user deposits funds into the pool and burned when a user withdraws funds from the pool.

### 3.3. DAO

DAO is a decentralized autonomous organization that provides its members with more lending capabilities. DAO members can borrow funds from the liquidity pool with less collateral.

User can verify their membership of DAO with DID using Polygon ID. (In development)

### 3.4. Credit Score & DAO score

Credit Score is a score that represents a user's creditworthiness. The credit score is calculated based on the user's transaction history, and the DAO score is calculated based on the user's contribution to the DAO.

These scores are used to determine the amount of funds a user can borrow from the liquidity pool.

### 3.5. KYC with DID

KYC with DID is a system that allows users to verify their identity using DID. This system is used to verify the user's identity when calculating the user's credit score and DAO score.

### 3.6. Cross-chain Messaging

Cross-chain Messaging is a messaging system that allows users to interact with the liquidity pool on different blockchains. This allows users to deposit and borrow funds on different blockchains.

It helps maintain all shTokens in one main chain and not bridging tokens. It is implemented using Chainlink's CCIP.

### 3.7. Automated Liquidation

Automated Liquidation is a system that automatically liquidates a user's collateral when the user's collateral value falls below the required collateral ratio.

It is implemented using Chainlink's Automation.

## 4. Usage

### 4.1. Basic Usage

**Getting Started**:
To start using Shylock Finance, users must first connect their wallet to the platform. Supported wallets include MetaMask, WalletConnect, and others compatible with Avalanche C-Chain, Ethereum Sepolia, and Polygon Mumbai.

**Depositing Funds**:

1. Navigate to the "Deposit" section.
2. Choose the desired blockchain network.
3. Select the amount and type of cryptocurrency to deposit.
4. Approve and confirm the transaction in your wallet.

**Borrowing Funds**:

1. Go to the "Borrow" section.
2. Your available borrowing limit based on your collateral and credit score will be displayed.
3. Select the amount and type of cryptocurrency you wish to borrow.
4. Approve and confirm the transaction.

**Repaying Loans**:

1. Visit the "Repay" section.
2. Choose the loan you wish to repay.
3. Input the repayment amount.
4. Confirm the repayment transaction in your wallet.

### 4.2. Examples

**Example 1 - Deposit and Borrow**:

- Alice wants to deposit 2 ETH into the liquidity pool.
- She navigates to the deposit section, selects ETH, and confirms the transaction.
- Based on her deposit, she is eligible to borrow up to 1.5 ETH worth of different cryptocurrencies.
- She decides to borrow 100 DAI and completes the transaction.

**Example 2 - DAO Membership and Increased Borrowing Limit**:

- Bob is a member of the DAO with a high DAO score.
- He deposits 1 ETH and is eligible to borrow up to 1.25 ETH worth of cryptocurrencies, higher than non-DAO members.
- Bob borrows 150 LINK and agrees to the terms of the loan.

**Example 3 - Automated Liquidation Scenario**:

- Charlie borrows funds against his 3 ETH collateral.
- If the value of ETH drops significantly, causing his collateral ratio to fall below the required threshold, the automated liquidation system is triggered.
- A portion of Charlie’s collateral is sold to bring the loan back into compliance.

**Example 4 - Cross-chain Borrowing**:

- David deposits 1 ETH into the liquidity pool on Avalanche C-Chain Fuji.
- He is eligible to borrow up to 1 ETH worth of cryptocurrencies on Avalanche C-Chain.
- David borrows 100 DAI on Ethereum Sepolia chain.

## 5. Testing & Development

### 5.1. Testing

- Unit Testing **@shylock_compound/test/unit**

    - ShylockCErc20.t.sol - Testing the basic functions of the ShylockCompound token
      - testMint
      - testRedeem
      - testAddDaoReserve
      - testWithdrawDaoReserve
      - testAddMemberReserve
      - testWithdrawMemberReserve
      - testBorrow
      - testRepayBorrow
      
  - ShylockGovernance.t.sol - Verify that functions that retrieve MemberCap, Reputation, etc. work well with
      - testGetDaoInfo
      - testGetMemberCollateralRate
      - testGetMemberCap
      - testGetMemberReputationInterest
      - testSetDaoCap
      - testSetProtocolToDaoGuaranteeRate
      - testSetDaoTierNumberAndThreshold
      - testSetDaoDataOrigin
      - testSetQuorum
      - testModifyReputation
  
  - ShylockGovernanceVote.t.sol - Test the Propose feature of your governance contract
 
- Integration Testing(Deploy Script) **@shylock_compound/script**
  
    - ShylockDeploy.s.sol - Deploy and Live deposing Test of Shylock Protocol without Crosschain Functionality
    - ShylockDeployCross.s.sol - Deploy and Live deposit testing of the Shylock Protocol, including cross-chain functionality.

### 5.2. Deployment

  #### Deployment
  December 11 @ 11:17 pm ET
 
  ** Avalanche Fuji Testnet **:

  mockERC20 deployed:  0xdA1E80e44B89F6a25e273f5e8A6E12a487e9fF65
  
  unitroller deployed:  0xF656e43A23571d07Dd7c770Ffb6228Aa355D1b8D
  
  ccipGateWay deployed:  0x57Fa6d0513fBDC0eA8dBe11e5eEe9a2A1D4675B4
  
  shERC20Crosschain deployed:  0x64D31bffC434C64f694Fdae11f3144413356A636
  
  priceOracle deployed:  0x63E00201EAA7888f4e6af7f7464A494D0979f729
 
  mockConsumer deployed:  0xe9aa3DC63bf97ae962D4ab23Aa0D3846A80C8e40
  
  governance deployed:  0x7A75a54dfdEdE792536415d152f49bf00dd3a941
 
  ** Ethereum Sepolia Testnet **:

  mockERC20 deployed:  0x7D93981c72d974999C0dAC29D6502f47f213e274
  
  ccipGateWay deployed:  0xF407f4Aa43E88be166AF4A2ee8b23f6b99Ea7d2a
  
  CTokenPool deployed:  0xeBbAE973653c0e4C309ce4E3D453dD6F54425C17

## 6. What We learned and cared about

**While implementing the lending part**

we had to completely change the existing compound structure, where the reserve deposited by Dao and members is not used for other Dao and members, but is compounded to pay higher interest to LPs.
we create a structure called AccountReserve and implemented getHypotheticalAccountReserveInternal function that checks for the reserve, similar to getHypotheticalAccountLiquidityInternal. 
We cared about the accuracy of the calculation because there had to be a percentage that the protocol guaranteed Dao and a percentage that Dao guaranteed the user. Along the way, we ran into problems like stack too deep.

**Lessons learned from creating CrossChain, DID, Chainlink Functions and more**

Impressed with the idea, we organized the structure early and started development
But it was not easy to integrate the CrossChain implementation, DID, Chainlink function, and price oracle into the complex low-collateral lending protocol structure.
Thanks to the modular structure, we were able to efficiently divide the work among team members. 

## 7. Roadmap & Future Plans

- [x] **Phase 1**: Basic Features
  - [x] Liquidity Pool
  - [x] shToken
  - [x] DAO
  - [x] Credit Score & DAO score
  - [x] DID
  - [x] Cross-chain Messaging
  - [x] Automated Liquidation
  - [x] Web UI
- [ ] **Phase 2**: Advanced Features
  - [ ] Polygon ZK-EVM Integration
  - [ ] Develop more advanced credit, DAO score system
  - [ ] Develop more advanced liquidation system
  - [ ] Dao verification with Polygon ID

## 8. License

MIT License

See [`LICENSE.md`](LICENSE.md) for details

## 9. Authors & Contact Information

### Sangwon Moon

- Email: san4865@gmail.com
- Github: [@sangwonmoonkr](github.com/sangwonmoonkr)
- LinkedIn: [문상원](https://www.linkedin.com/in/sangwon-moon-39ba0211a/)
- Twitter: [@spotlss_mnd](https://twitter.com/spotlss_mnd)
- Telegram: [@icanply](https://t.me/icanply)

### Seungmin Jeon

- Email: 
- Github: 
- LinkedIn:
- Twitter:
- Telegram:

### Wonjae Choi

- Email: [choi@wonj.me](mailto:choi@wonj.me)
- Github: [@wonj1012](github.com/wonj1012)
- LinkedIn: [wonj](https://www.linkedin.com/in/wonj/)
- Twitter: [@0xwonj](https://twitter.com/0xwonj)
- Telegram: [@wonj1012](https://t.me/wonj1012)
