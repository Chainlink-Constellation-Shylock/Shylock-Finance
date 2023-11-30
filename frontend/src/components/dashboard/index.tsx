export default function Dashboard() {
  return (
    <div className="flex flex-col h-screen items-center justify-center">
      <div className="font-mono text-xl mt-1">
        Dashboard
      </div>
      <div className="flex flex-col mt-1">
        <button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          Check Your DAO Point
        </button>
      </div>
    </div>
  )
}