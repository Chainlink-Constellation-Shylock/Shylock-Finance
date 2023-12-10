import type { Metadata } from 'next'
import './globals.css'
import { Web3ModalProvider } from "../context/Web3Modal"

export const metadata: Metadata = {
  title: 'Shylock Finance',
  description: 'Undercollateralized, Multichain Lending Protocol based on DAOs',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Web3ModalProvider>{children}</Web3ModalProvider>
      </body>
    </html>
  )
}