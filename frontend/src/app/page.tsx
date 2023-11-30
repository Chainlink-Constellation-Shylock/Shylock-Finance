import Link from 'next/link'


export default function Home() {
  return (
    <main className="flex flex-col h-screen items-center justify-center">
      <div className="font-mono text-xl mt-3">
        Shylock Finance
      </div>
      <div className="flex flex-col mt-3">
        <Link href="/dashboard" passHref>
          <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Go to Dashboard
          </button>
        </Link>
      </div>
    </main>
  )
}
