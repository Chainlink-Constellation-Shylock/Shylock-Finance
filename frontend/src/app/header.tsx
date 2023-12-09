import Link from "next/link";
import KeyIcon from "@/components/ui/keyIcon";

export default function Header() {
  return(
    <header className="px-4 lg:px-6 h-20 flex items-center">
      <Link className="flex items-center justify-center" href="/">
        <KeyIcon className="h-6 w-6 text-[#755f44]" />
        <span className="sr-only">Shylock Finance</span>
      </Link>
      <nav className="ml-auto flex gap-4 sm:gap-6">
        <Link className="text-sm font-medium hover:bg-[#eeeeee] px-4 py-2 rounded-md text-[#755f44]" href="/dashboard">
          Dashboard
        </Link>
        <Link className="text-sm font-medium hover:bg-[#eeeeee] px-4 py-2 rounded-md text-[#755f44]" href="#">
          Lending
        </Link>
      </nav>
    </header>
  )
}