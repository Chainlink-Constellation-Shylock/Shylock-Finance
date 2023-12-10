"use client"

import { TabsList, Tabs } from "@/app/components/ui/tabs"
import { useState } from "react"
import UniswapScore from "./ssUniswapScore";
import MockScore from "./ssMockScore";

export default function DAOTabComponent() {
    const [activeTab, setActiveTab] = useState("MockDAO");

    const isUniswap = activeTab === "Uniswap";

    const handleUniTab = () => {
        setActiveTab('Uniswap');
    };

    const handleMockTab = () => {
        setActiveTab('MockDAO');
    }

    return (
        <div className="flex-1 border-[#755f44] pr-4">
            <Tabs className="w-full mb-4">
                <TabsList className="flex gap-2">
                    <button
                        className={`px-2 py-1 rounded-md m-1 ${isUniswap ? 'bg-[#f5f1e8] text-black' : 'bg-[#755f44] text-white'}`}
                        onClick={handleMockTab}
                    >
                        😛 MockDAO
                    </button>
                    <button 
                        className={`px-2 py-1 rounded-md m-1 ${isUniswap ? 'bg-[#755f44] text-white' : 'bg-[#f5f1e8] text-black'}`}
                        onClick={handleUniTab}
                    >
                        🦄 Uniswap
                    </button>
                </TabsList>
                <>
                    {isUniswap ? (<UniswapScore />) : (<MockScore />)}
                </>
            </Tabs>
        </div>
    );
}