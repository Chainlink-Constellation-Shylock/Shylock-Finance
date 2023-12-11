"use client"

import { TabsList, Tabs } from "@/app/components/ui/tabs"
import { useState, useEffect } from "react"
import { useWeb3ModalAccount } from '@web3modal/ethers5/react';

import LendBox from "./ssDepositBox";
import AddCollateralBox from "./ssAddCollateralBox";
import BorrowBox from "./ssBorrowBox";
import RepayModal from "./ssRepayBox";
import WithdrawBox from "./ssWithdrawBox";
import RedeemBox from "./ssRedeemBox";
import { CardContent, Card } from "@/app/components/ui/card";

export default function MonetaryActionComponent() {
    const [activeTab, setActiveTab] = useState("Deposit");
    const [isComponentMounted, setIsComponentMounted] = useState(false);

    const { isConnected, chainId } = useWeb3ModalAccount();

    const isDeposit = activeTab === "Deposit";
    const isWithdraw = activeTab === "Withdraw";
    const isBorrow = activeTab === "Borrow";
    const isRepay = activeTab === "Repay";

    const handleDepositTab = () => {
        setActiveTab('Deposit');
    };

    const handleWithdrawTab = () => {
        setActiveTab('Withdraw');
    }

    const handleBorrowTab = () => {
        setActiveTab('Borrow');
    }

    const handleRepayTab = () => {
        setActiveTab('Repay');
    }

    const isPolygonZkEVMTestnet = chainId === 1442;

    useEffect(() => {
        setIsComponentMounted(true);
    }, []);

    if (!isComponentMounted) {
        return <div>Loading...</div>;
    }

    return (
        <div className="flex-1 border-[#755f44] pr-4">
            <Tabs className="w-full mb-4">
                <TabsList className="flex gap-2">
                    <button
                        className={`px-2 py-1 rounded-md m-2 ${isDeposit ? 'bg-[#755f44] text-white' : 'bg-[#f5f1e8] text-black'}`}
                        onClick={handleDepositTab}
                    >
                        Deposit
                    </button>
                    <button 
                        className={`px-2 py-1 rounded-md m-2 ${isWithdraw ? 'bg-[#755f44] text-white' : 'bg-[#f5f1e8] text-black'}`}
                        onClick={handleWithdrawTab}
                    >
                        Withdraw
                    </button>
                    <button 
                        className={`px-2 py-1 rounded-md m-2 ${isBorrow ? 'bg-[#755f44] text-white' : 'bg-[#f5f1e8] text-black'}`}
                        onClick={handleBorrowTab}
                    >
                        Borrow
                    </button>
                    <button 
                        className={`px-2 py-1 rounded-md m-2 ${isRepay ? 'bg-[#755f44] text-white' : 'bg-[#f5f1e8] text-black'}`}
                        onClick={handleRepayTab}
                    >
                        Repay
                    </button>
                </TabsList>
                <Card className="w-full p-8 rounded-lg shadow-md text-[#755f44] border-[#a67b5b] bg-white shadow-[0px_0px_8px_rgba(0,0,0,0.1)] relative overflow-hidden">
                    <CardContent className="w-4/5 h-4/5 flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
                    <div className="w-full">
                        {isConnected && isPolygonZkEVMTestnet && (
                            <div className="flex flex-row justify-between">
                                <div className="mr-25">
                                    <p>Coming Soon...</p>
                                </div>
                            </div>
                        )}
                        {isConnected && isDeposit && !isPolygonZkEVMTestnet && (
                            <div className="flex flex-row justify-between">
                                <div className="mr-25">
                                    <LendBox />
                                </div>
                                <div className="">
                                    <AddCollateralBox />
                                </div>
                            </div>
                        )}
                        {isConnected && isWithdraw && !isPolygonZkEVMTestnet && (
                            <div className="flex flex-row justify-between">
                                <div className="mr-25">
                                    <WithdrawBox />
                                </div>
                                <div className="">
                                    <RedeemBox />
                                </div>
                            </div>
                        )}
                        {isConnected && isBorrow && !isPolygonZkEVMTestnet && (<BorrowBox />)}
                        {isConnected && isRepay && !isPolygonZkEVMTestnet && (<RepayModal />) }
                        {!isConnected && (
                            <div className="flex-1 pl-4">
                                <div className="flex items-center justify-between">
                                    <p className="text-medium font-bold mt-2">Connect Wallet to continue</p>
                                </div>
                            </div>
                        
                        )}
                    </div>
                    </CardContent>
                </Card>
                
            </Tabs>
        </div>
    );
}