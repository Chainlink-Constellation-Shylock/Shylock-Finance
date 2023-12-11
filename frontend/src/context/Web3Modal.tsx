"use client"
import React from 'react';
import { createWeb3Modal, defaultConfig } from '@web3modal/ethers5/react'

// 1. Get projectId
const projectId = process.env.NEXT_PUBLIC_PROJECT_ID ?? "";

// 2. Set chains
const avaFujiTestnet = {
  chainId: 43113,
  name: 'Avalanche Fuji Testnet',
  currency: 'AVAX',
  explorerUrl: 'https://testnet.snowtrace.io/',
  rpcUrl: process.env.NEXT_PUBLIC_FUJI_RPC ?? 'https://api.avax-test.network/'
}

const polygonZkEVMTestnet = {
    chainId: 1442,
    name: 'Polygon zkEVM Testnet',
    currency: 'ETH',
    explorerUrl: 'https://testnet-zkevm.polygonscan.com/',
    rpcUrl: 'https://rpc.public.zkevm-test.net/'
}

const ethereumSepoliaTestnet = {
    chainId: 11155111,
    name: 'Ethereum Sepolia Testnet',
    currency: 'ETH',
    explorerUrl: 'https://sepolia.etherscan.io',
    rpcUrl: 'https://rpc.sepolia.org'
}

// 3. Create modal
const metadata = {
  name: 'Shylock Finance',
  description: 'Multichain Undercollateralized Lending Protocol for DAO participants',
  url: 'http://localhost:3001',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

createWeb3Modal({
  ethersConfig: defaultConfig({ metadata }),
  chains: [avaFujiTestnet, ethereumSepoliaTestnet, polygonZkEVMTestnet],
  projectId,
  themeMode: 'light',
  themeVariables: {
    '--w3m-color-mix': '#ffffff',
    '--w3m-color-mix-strength': 40,
    '--w3m-accent': '#755f44',
  }
})

export function Web3ModalProvider({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}