import { CardHeader, CardContent, Card } from "@/components/ui/card"

export default function Dashboard() {
  return (
    <main className="flex-1">
      <section className="w-full py-12 md:py-24 lg:py-32 xl:py-48">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-start space-y-4 md:space-y-8 lg:space-y-12 text-left">
            <h1 className="text-2xl font-bold">Dashboard</h1>
            <div className="w-full">
              <Card className="papyrus-border w-full p-8 rounded-lg shadow-md bg-white text-[#755f44] ">
                <CardHeader className="flex justify-between items-center border-b-2 border-[#755f44] pb-2">
                  <h2 className="text-2xl font-bold">Dashboard Overview</h2>
                </CardHeader>
                <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
                  <div className="flex-1 border-r-2 border-[#755f44] pr-4">
                    <div className="flex items-center justify-between">
                      <p>DAO Activity Points:</p>
                      <p>XXX</p>
                    </div>
                    <div className="flex items-center justify-between">
                      <p>Reputation Points:</p>
                      <p>XXX</p>
                    </div>
                    <button className="bg-[#755f44] text-white px-4 py-2 mt-4 rounded-md">Check My Score</button>
                  </div>
                  <div className="flex-1 pl-4">
                    <div className="flex items-center justify-between">
                      <p>DID (Digital Identity Document):</p>
                      <p>XXX</p>
                    </div>
                    <button className="bg-[#755f44] text-white px-4 py-2 mt-4 rounded-md">Get Polygon ID</button>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </section>
    </main>
  )
}
