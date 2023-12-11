# Shylock Finance

## 1. Introduction

Shylock Finance is an innovative DeFi project designed to facilitate **cross-chain lending and borrowing**. At its core, it leverages the fundamental system of the **Compound Protocol** but stands out with its unique feature: an **under-collateralized loan** system.

This groundbreaking approach allows users to borrow amounts exceeding their collateral value. This is made possible through a comprehensive credit score system, DAO membership, and enhanced KYC procedures using DID technology, ensuring both security and accessibility.

**What is Shylock?**

<a href="https://www.metmuseum.org/art/collection/search/400327">
    <img src="assets/shylock.png" alt='Shylock (from "Twelve Characters from Shakespeare - John Hamilton Mortimer")' width="50%" height="50%">
</a>

The name **"Shylock"** is inspired by a character from William Shakespeare's "The Merchant of Venice." Known as a stringent moneylender, Shylock's character is synonymous with strict lending terms. In contrast, Shylock Finance reinterprets this concept for the DeFi world, focusing on innovative and flexible lending solutions. While drawing inspiration from Shylock’s adherence to strict principles, our project diverges by promoting a more equitable and accessible financial ecosystem.

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

### 3.4. Credit Score & DAO score

Credit Score is a score that represents a user's creditworthiness. The credit score is calculated based on the user's transaction history, and the DAO score is calculated based on the user's contribution to the DAO.

### 3.5. DID

DID is a decentralized identifier that is used to verify a user's identity. The DID is used to provide users with a more secure and reliable credit score.

### 3.6. Cross-chain Messaging

Cross-chain Messaging is a messaging system that allows users to interact with the liquidity pool on different blockchains. This allows users to deposit and borrow funds on different blockchains.

### 3.7. Automated Liquidation

Automated Liquidation is a system that automatically liquidates a user's collateral when the user's collateral value falls below the required collateral ratio.

## 4. Usage

### 4.1. Basic Usage

### 4.2. Examples

## 5. Testing & Development

### 5.1. Testing

### 5.2. Contributing

## 6. Roadmap & Future Plans

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

## 7. License

MIT License

see [`LICENSE.md`](LICENSE.md) for details

## 8. Authors & Contact Information

### Sangwon Moon

- Email:
- Github:
- LinkedIn:
- Twitter:
- Telegram:

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
