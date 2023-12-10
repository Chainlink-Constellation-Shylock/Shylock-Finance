import { TabsContent } from "../ui/tabs"
import { useState } from "react"

export default function UniswapScore() {
  const [daoScore, setDaoScore] = useState(0);

  const getDaoScore = async () => {
    try {
    const response = await fetch('https://your-api-endpoint.com/score');
    if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
    }
    const data = await response.json();
        setDaoScore(data.score);
    } catch (error) {
        console.error("Failed to fetch DAO score:", error);
        setDaoScore(0);
    }
  };

  return (
    <div>
      <TabsContent>
        <div className="flex items-center justify-between m-1">
          <p>Your DAO Activity Points:</p>
          <p>XXX</p>
        </div>
        <div className="flex items-center justify-between m-1">
          <p>Your Reputation Points:</p>
          <p>XXX</p>
        </div>
        <p className="text-sm text-gray-600 mt-4">
          ℹ️ Disclaimer: This is for test purpose, to calculate your score based on your activity on Uniswap. 
        </p>
        <p className="text-sm text-gray-600">
          You <b>CANNOT</b> borrow money from Shylock Finance with this score.
        </p>
        <button 
          className="bg-[#755f44] text-white px-4 py-2 mt-4 rounded-md"
        >
          Check My Score
        </button>
      </TabsContent>
    </div>
  )
}