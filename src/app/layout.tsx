import type { Metadata } from 'next'
import { Source_Sans_3 } from 'next/font/google'
import type { ReactNode } from 'react'
import ApplicationShell from '@/components/ApplicationShell'
import '@/styles/theme.css'
import '@/styles/global.css'

const sourceSans = Source_Sans_3({
  subsets: ['latin'],
  weight: ['400', '600', '700'],
  variable: '--font-source-sans',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Retention Copilot',
  description: 'See who is likely to leave, why, and what to do next.',
}

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" className={sourceSans.variable}>
      <body>
        <ApplicationShell>{children}</ApplicationShell>
      </body>
    </html>
  )
}
