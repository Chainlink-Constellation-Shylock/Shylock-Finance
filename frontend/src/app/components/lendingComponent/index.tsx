import { ShylockBox } from "./ssBoxComponent";

export default function Lending() {
  return (
    <main className="flex-1">
      <section className="w-full py-12 md:py-32 lg:py-32 xl:py-8">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-center space-y-4 md:space-y-4 lg:space-y-12 text-left">
            <h1 className="text-2xl font-bold">Market</h1>
            <ShylockBox />
          </div>
        </div>
      </section>
    </main>
  )
}
