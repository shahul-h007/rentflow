import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "sonner";
import { ServiceWorker } from "@/components/service-worker";
export const metadata: Metadata={title:"RentFlow — Smart House Rent & Expense Management",description:"Shared-house rent, bills and settlements in one calm place.",manifest:"/manifest.webmanifest"};
export default function RootLayout({children}:{children:React.ReactNode}){
  return (
    <html lang="en">
      <head>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
      </head>
      <body className="bg-background text-foreground font-sans antialiased">
        {children}
        <ServiceWorker/>
        <Toaster richColors position="top-right"/>
      </body>
    </html>
  );
}

