import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "sonner";
import { ServiceWorker } from "@/components/service-worker";
export const metadata: Metadata={title:"RentFlow — Smart House Rent & Expense Management",description:"Shared-house rent, bills and settlements in one calm place.",manifest:"/manifest.webmanifest"};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}<ServiceWorker/><Toaster richColors position="top-right"/></body></html>}
