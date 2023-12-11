import { TabsContent } from "../ui/tabs"
import { BulletChart } from "../ui/bulletChart"

export default function MockScore() {
  return (
    <div className="w-full items-center">
      <TabsContent className="flex flex-row justify-between m-5">
        <div className="flex flex-col items-center justify-between m-2">
          <p className="text-m font-bold">Your DAO Activity Points:</p>
          <BulletChart isDaoScore={true} score={60} targetValue={50} />
        </div>
        <div className="flex flex-col items-center justify-between m-2">
          <p className="text-m font-bold">Your Reputation Points:</p>
          <BulletChart isDaoScore={false} score={50} />
        </div>
      </TabsContent>
      <TabsContent className="flex flex-col">
        <div className="flex items-center justify-between m-2">
          <p className="text-m font-bold">MockDAO Reputation Points:</p>
          <p className="text-m font-bold">5000</p>
        </div>
        <div className="flex items-center justify-between m-2">
          <p className="text-m font-bold">Total Cap of MockDAO:</p>
          <p className="text-m font-bold">10 ETH</p>
        </div>
        <p className="text-sm text-gray-600 mt-4">
          ℹ️ Disclaimer: This is a <b>fake DAO</b> for testing purpose. 
          Scores of MockDAO and you will be calculated like above. 
        </p>
      </TabsContent>
    </div>
  )
}