import { TabsContent } from "../ui/tabs"

export default function MockScore() {
  return (
    <div>
      <TabsContent>
        <div className="flex items-center justify-between m-1">
          <p>Your DAO Activity Points:</p>
          <p>60</p>
        </div>
        <div className="flex items-center justify-between m-1">
          <p>Your Reputation Points:</p>
          <p>50</p>
        </div>
        <p className="text-sm text-gray-600 mt-4">
          ℹ️ Disclaimer: This is a <b>fake DAO</b> for testing purpose. 
          Scores of MockDAO and you will be calculated like above. 
        </p>
      </TabsContent>
    </div>
  )
}