import { CardHeader, CardContent, Card } from "@/app/components/ui/card";
import DAOTabComponent from "./ssDaoScore";
import QRCodeGenerator from "./ssQRGenerator";

function StatBox() {
  return (
    <div className="w-4/5">
      <Card className="w-full p-8 rounded-lg shadow-md text-[#755f44] border-[#a67b5b] bg-white shadow-[0px_0px_8px_rgba(0,0,0,0.1)] relative overflow-hidden">
        <CardHeader className="flex justify-between items-start border-[#755f44]">
          <h2 className="text-2xl font-bold">Overview</h2>
        </CardHeader>
        <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
          <DAOTabComponent />
        </CardContent>
      </Card>
    </div>
  )
}


function DIDBox() {
  return (
    <div className="w-4/5">
      <Card className="w-full p-8 rounded-lg shadow-md text-[#755f44] border-[#a67b5b] bg-white shadow-[0px_0px_8px_rgba(0,0,0,0.1)] relative overflow-hidden">
        <CardHeader className="flex justify-between items-start border-b-2 border-[#755f44]">
          <h2 className="text-2xl font-bold">Your DID Overview</h2>
        </CardHeader>
        <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
          <div className="flex-1 pl-4">
              <div className="flex items-center justify-between mt-2">
                <p className="text-medium font-bold">Get Your DID through Polygon ID</p>
              </div>
              <QRCodeGenerator />
          </div>
          <div className="flex-1 pl-4">
            <div className="flex items-center justify-between mt-2">
              <p className="text-medium font-bold">Get Verified</p>
            </div>
            <button className="bg-[#755f44] text-white px-4 py-2 mt-14 rounded-md">Verify Your DID</button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

export { StatBox, DIDBox }