// @TODO: Fix Dashboard to Lending
import Dashboard from "@/app/components/dashboardComponent";
import Footer from "@/app/footer";
import Header from "@/app/header";

export default function Page() {
  return (
    <main>
      <div className="flex flex-col min-h-[100vh] bg-[#f5f1e8]">
        <Header />
        <Dashboard />
        <Footer />
      </div>
    </main>
  )
}