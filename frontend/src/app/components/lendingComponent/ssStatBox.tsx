import { Card, CardContent, CardHeader } from '../ui/card';
import MemberComponent from './ssMemberStatus';

export default function MemberStatBox() {
  return (
    <div className="w-4/5">
      <Card className="w-full p-8 rounded-lg shadow-md text-[#755f44] border-[#a67b5b] bg-white shadow-[0px_0px_8px_rgba(0,0,0,0.1)] relative overflow-hidden">
        <CardHeader className="flex justify-between items-start border-[#755f44]">
          <h2 className="text-2xl font-bold">Overview</h2>
        </CardHeader>
        <CardContent className="flex flex-col lg:flex-row space-y-4 lg:space-y-0 lg:space-x-4">
          <MemberComponent />
        </CardContent>
      </Card>
    </div>
  )
}