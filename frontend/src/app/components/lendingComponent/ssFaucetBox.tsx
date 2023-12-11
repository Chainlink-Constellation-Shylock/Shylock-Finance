"use client";
import React, {useState} from 'react';
import { Card, CardContent, CardHeader } from '../ui/card';
import { FaucetAbi } from '../../utils/abi/FaucetAbi'; 
import { ethers } from 'ethers';
import { useWeb3ModalAccount, useWeb3ModalProvider } from '@web3modal/ethers5/react';
import { toast } from 'react-toastify';


export default function FaucetBox() {
  const faucetAddress = "0xB5868cdE0FD3140B99C265275377482f012778ca";
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  console.log(isConnected);
  console.log(chainId);
  const { walletProvider } = useWeb3ModalProvider();
  console.log(walletProvider);
  const handleFaucet = async () => {

    if (!walletProvider || !isConnected || chainId != 43113) {
      console.log('Wallet not connected');
      return;
    }

    try {
      // Connect to the network
      const provider = new ethers.providers.Web3Provider(walletProvider);
      const signer = provider.getSigner();

      const contract = new ethers.Contract(faucetAddress, FaucetAbi, signer);
      toast.info('Depositing...', {
        position: "top-right",
        autoClose: 15000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });

      const tx = await contract.getSomeToken();

      console.log('Transaction:', tx);

      // Wait for the transaction to be mined
      await tx.wait();
      console.log('Faucet transaction completed');
      toast.success(`Success! Here is your transaction:${tx.receipt.transactionHash} `, {
        position: "top-right",
        autoClose: 18000,
        hideProgressBar: false,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
        });
    } catch (error) {
      console.error('Error during deposit transaction:', error);
    }
  };
  return (
    <div className="w-4/5">
      <Card className="w-full p-8 rounded-lg shadow-md text-[#755f44] border-[#a67b5b] bg-white shadow-[0px_0px_8px_rgba(0,0,0,0.1)] relative overflow-hidden">
        <CardHeader className="flex justify-between items-start border-[#755f44]">
          <h2 className="text-2xl font-bold">Faucet</h2>
        </CardHeader>
        <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
          <button onClick={() => handleFaucet()} className="bg-[#755f44] text-white px-4 py-2 mt-4 rounded-md">Get Fuji DAI for free</button>
        </CardContent>
      </Card>
    </div>
  )
}