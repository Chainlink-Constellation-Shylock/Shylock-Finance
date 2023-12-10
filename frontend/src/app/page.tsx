import React from "react";
import Link from "next/link";
import Header from "@/app/header";
import Footer from "@/app/footer";

export default function Home() {
  return (
    <div className="flex flex-col min-h-[100vh] bg-[#f5f1e8]">
      <Header />
      <main className="flex-1">
        <section className="w-full py-12 md:py-24 lg:py-32 xl:py-48">
          <div className="container px-4 md:px-6">
            <div className="flex flex-col items-center space-y-4 text-center">
              <div className="space-y-2">
                <h1 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl text-[#755f44]">
                  Welcome to Shylock Finance
                </h1>
                <p className="mx-auto max-w-[700px] text-[#755f44] md:text-xl dark:text-gray-400">
                  Unlock Boundless Opportunities with Your DAO Activities.
                </p>
              </div>
              <div className="space-x-4">
                <Link
                  className="inline-flex h-9 items-center justify-center rounded-md bg-[#755f44] px-4 py-2 text-sm font-medium text-[#f5f1e8] shadow transition-colors hover:bg-[#755f44]/90 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-gray-950 disabled:pointer-events-none disabled:opacity-50 dark:bg-gray-50 dark:text-gray-900 dark:hover:bg-gray-50/90 dark:focus-visible:ring-gray-300"
                  href="/dashboard"
                >
                  Get Started
                </Link>
                <Link
                  className="inline-flex h-9 items-center justify-center rounded-md border border-[#755f44] bg-[#f5f1e8] px-4 py-2 text-sm font-medium text-[#755f44] shadow-sm transition-colors hover:bg-gray-100 hover:text-[#755f44] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-gray-950 disabled:pointer-events-none disabled:opacity-50 dark:border-gray-800 dark:border-gray-800 dark:bg-gray-950 dark:hover:bg-gray-800 dark:hover:text-gray-50 dark:focus-visible:ring-gray-300"
                  href="#"
                >
                  Learn more
                </Link>
              </div>
            </div>
          </div>
        </section>
        <section className="w-full py-12 md:py-24 lg:py-32">
          <div className="container grid items-center justify-center gap-4 px-4 text-center md:px-6 lg:gap-10">
            <div className="space-y-3">
              <h2 className="text-3xl font-bold tracking-tighter sm:text-4xl md:text-5xl text-[#755f44]">
                Our Technologies
              </h2>
              <p className="mx-auto max-w-[700px] text-[#755f44] md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                We are based on the industry-leading technologies.
              </p>
            </div>
            <div className="grid w-full grid-cols-2 lg:grid-cols-4 items-center justify-center gap-8 lg:gap-12 [&>img]:mx-auto">
              <div className="flex flex-col">
                <img
                  src="/chainlink_ccip.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Deposit & Borrow</p>
                <p className="text-[#755f44]">at any chain with CCIP</p>
              </div>
              <div className="flex flex-col">
                <img
                  src="/chainlink_automation.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Liquidation enabled</p>
                <p className="text-[#755f44]">by Chainlink Automation</p>
              </div>
              <div className="flex flex-col">
                <img
                  src="/chainlink_functions.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Trust-Minimized data retrieval</p>
                <p className="text-[#755f44]">through Chainlink Functions</p>
              </div>
              
              <div className="flex flex-col">
                <img
                  src="/chainlink_oracle.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Fast, Secure Market Data</p>
                <p className="text-[#755f44]">from Chainlink Oracle</p>
              </div>
            </div><div className="grid w-full grid-cols-2 lg:grid-cols-4 items-center justify-center gap-8 lg:gap-12 [&>img]:mx-auto">
              <div className="flex flex-col">
                <img
                  src="/the_graph.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Best-in-class on-chain data</p>
                <p className="text-[#755f44]">from The Graph</p>
              </div>
              <div className="flex flex-col">
                <img
                  src="/avalanche.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-9"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Lightning fast, scalable</p>
                <p className="text-[#755f44]">Blockchain Experience</p>
              </div>
              <div className="flex flex-col">
                <img
                  src="/polygon.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Bring Ethereum to everyone</p>
                <p className="text-[#755f44]">with Polygon zkEVM</p>
              </div>
              
              <div className="flex flex-col">
                <img
                  src="/polygon.svg"
                  alt="Logo"
                  className="aspect-[2/1] overflow-hidden rounded-lg object-contain object-center ml-8"
                  height="70"
                  width="140"
                />
                <p className="text-[#755f44]">Trusted Digital Identity</p>
                <p className="text-[#755f44]">with Polygon ID</p>
              </div>
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </div>
  )
}

