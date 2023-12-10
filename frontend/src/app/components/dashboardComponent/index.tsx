import { StatBox, DIDBox } from "./ssBoxComponent";

export default function Dashboard() {
  return (
    <main className="flex-1">
      <section className="w-full py-12 md:py-32 lg:py-32 xl:py-8">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-center space-y-4 md:space-y-4 lg:space-y-12 text-left">
            <h1 className="text-2xl font-bold">Your Status in DAOs</h1>
            <StatBox />
          </div>
        </div>
      </section>
      <section className="w-full py-12 md:py-24 lg:py-32 xl:py-8">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-center space-y-4 md:space-y-8 lg:space-y-12 text-left">
            <h1 className="text-2xl font-bold">DID</h1>
            <DIDBox />
          </div>
        </div>
      </section>
    </main>
  )
}
