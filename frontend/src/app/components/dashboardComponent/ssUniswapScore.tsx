import { TabsContent } from "../ui/tabs";
import { useState } from "react";
import { useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { BulletChart } from "../ui/bulletChart";

export default function UniswapScore() {
  const { address } = useWeb3ModalAccount();
  const [daoScore, setDaoScore] = useState(61);
  const [reputationScore, setReputationScore] = useState(49);

  const [isButtonDisabled, setIsButtonDisabled] = useState(false);

  const getDaoScore = async () => {
    setIsButtonDisabled(true); // Disable the button
    try {
      const response = await fetch(process.env.NEXT_PUBLIC_API_URL + "/uniswapgovernance.eth/" + address);
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }
      const data = await response.json();
      console.log(data);
      const daoScore = (data.snapshot + data.uniswap) / 2;
      setDaoScore(daoScore);
      setReputationScore(50);
    } catch (error) {
      console.error("Failed to fetch DAO score:", error);
      setDaoScore(0);
      setReputationScore(0);
    } finally {
      setTimeout(() => setIsButtonDisabled(false), 30000); // Re-enable the button after 30 seconds
    }
  };

  const buttonStyle = isButtonDisabled
    ? "bg-gray-400 text-white px-4 py-2 mt-4 rounded-md"
    : "bg-[#755f44] text-white px-4 py-2 mt-4 rounded-md";

  return (
    <div className="w-full items-center">
      <TabsContent className="flex flex-row justify-between m-5">
        <div className="flex flex-col items-center justify-between m-2">
          <p className="text-m font-bold">Your DAO Activity Points</p>
          <BulletChart isDaoScore={true} score={daoScore} targetValue={55} />
        </div>
        <div className="flex flex-col items-center justify-between m-2">
          <p className="text-m font-bold">Your Reputation Points</p>
          <BulletChart isDaoScore={false} score={reputationScore} />
        </div>
      </TabsContent>
      <TabsContent className="flex flex-col">
        <p className="text-sm text-gray-600 mt-4">
          ℹ️ Disclaimer: This is for test purpose, to calculate your score based on your activity on Uniswap. 
        </p>
        <p className="text-sm text-gray-600">
          ℹ️ You <b>CANNOT</b> borrow money from Shylock Finance with this score.
        </p>
        <p className="text-sm text-gray-600">
          ℹ️ Your score is highly likely to be <b>0</b>. <b>DO NOT</b> push the button multiple times.
        </p>
        <button 
          className={buttonStyle}
          onClick={getDaoScore}
          disabled={isButtonDisabled}
        >
          {isButtonDisabled ? "Wait for a sec..." : "Check My Score"}
        </button>
      </TabsContent>
    </div>
  )
}