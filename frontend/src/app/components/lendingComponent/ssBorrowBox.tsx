import { TabsContent } from "../ui/tabs";
import { useState } from "react";
import { useWeb3ModalAccount } from '@web3modal/ethers5/react';

export default function BorrowBox() {
  const { address } = useWeb3ModalAccount();
  const [daoScore, setDaoScore] = useState(0);
  const [reputationScore, setReputationScore] = useState(0);

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
    <div>
      <TabsContent>
        <div className="flex items-center justify-between m-2">
          <p>Your DAO Activity Points:</p>
          <p>{daoScore} / 100</p>
        </div>
        <div className="flex items-center justify-between m-2">
          <p>Your Reputation Points:</p>
          <p>{reputationScore} / 100</p>
        </div>
        <p className="text-sm text-gray-600 mt-4">
          ℹ️ Disclaimer: This is for test purpose, to calculate your score based on your activity on Uniswap. 
        </p>
        <p className="text-sm text-gray-600">
          You <b>CANNOT</b> borrow money from Shylock Finance with this score.
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