"use client"

import { CardContent } from "@/app/components/ui/card";
import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { ethers } from 'ethers';
import { ShylockComptrollerAbi } from '@/app/utils/abi/shylockComptrollerAbi';
import { useState, useEffect } from "react";

export default function MemberComponent() {
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  const [data, setData] = useState({ totalDeposit: "0", totalBorrow: "0" });
  const [isLoading, setIsLoading] = useState(true);
  const isAvalancheFuji = chainId === 43113;

  async function getDepositAndBorrows() {
    if (isAvalancheFuji && isConnected && walletProvider) {
      const provider = new ethers.providers.Web3Provider(walletProvider);
      const signer = provider.getSigner();
      const shylockComptroller = new ethers.Contract(
        "0x3f0A0EA2f86baE6362CF9799B523BA06647Da018",
        ShylockComptrollerAbi,
        signer
      );
      try {
        const totalDeposit = await shylockComptroller.callStatic.getAllAccountCtokenBalance(address).then((result: ethers.BigNumberish) => {
          return ethers.utils.formatUnits(result, 18);
        });
        console.log("totalDeposit", totalDeposit);
        const totalBorrow = await shylockComptroller.callStatic.getAllAccountBorrow(address).then((result: ethers.BigNumberish) => {
          return ethers.utils.formatUnits(result, 18);
        });
        console.log("totalBorrow", totalBorrow);
        return { totalDeposit, totalBorrow };
      } catch (error) {
        console.log(error);
        return { totalDeposit: "0", totalBorrow: "0" };
      }
    } else {
      return { totalDeposit: "0", totalBorrow: "0" };
    }
  };

  useEffect(() => {
    setIsLoading(true);
    if (!isConnected) {
      setIsLoading(false);
      return;
    }
    getDepositAndBorrows().then(result => {
      setData(result);
      setIsLoading(false);
    });
  }, [chainId, isConnected, walletProvider, address]);

if (isLoading) {
  return <div>Loading...</div>; // Or any other loading state representation
}
  if (isLoading) {
    return <div>Loading...</div>;
  }

  return (
    <>
      {isAvalancheFuji && isConnected 
        && (
          <div className="flex-1 border-[#755f44] pr-4">
            <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
              <div className="flex-1 pl-4">
                <div className="flex items-center justify-between">
                  <p className="text-medium font-bold mt-2">You belong to:</p>
                  <p className="text-medium font-bold mt-2">😛 MockDAO</p>
                </div>
                <div className="flex items-center justify-between">
                  <p className="text-medium font-bold mt-2">Total Deposited:</p>
                  <p className="text-medium font-bold mt-2">{data.totalDeposit} ETH</p>
                </div>
                <div className="flex items-center justify-between">
                  <p className="text-medium font-bold mt-2">Total Borrowed:</p>
                  <p className="text-medium font-bold mt-2">{data.totalBorrow} ETH</p>
                </div>
              </div>
            </CardContent>
          </div>
        )
      }
      {!isAvalancheFuji && isConnected && (
        <div className="flex-1 border-[#755f44] pr-4">
          <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
            <div className="flex-1 pl-4">
              <div className="flex items-center justify-between">
                <p className="text-medium font-bold mt-2">Please Connect to Avalanche Fuji Testnet to see your state</p>
              </div>
            </div>
          </CardContent>
        </div>
      )}
      {!isConnected && (
        <div className="flex-1 border-[#755f44] pr-4">
          <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
            <div className="flex-1 pl-4">
              <div className="flex items-center justify-between">
                <p className="text-medium font-bold mt-2">Please Connect to Wallet</p>
              </div>
            </div>
          </CardContent>
        </div>
      )}
    </>
  );
}