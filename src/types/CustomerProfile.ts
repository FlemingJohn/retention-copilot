import type { CustomerSummary } from '@/types/CustomerSummary'

export interface CustomerProfile extends CustomerSummary {
  state: string
  tenureMonths: number
  activePolicies: number
  totalMonthlyPremium: number
  productsHeld: string | null
  latePayments: number
  failedPayments: number
  lateOrFailedRate: number | null
  claimsCount: number
  openClaims: number
  rejectedClaims: number
  ticketsCount: number
  openTickets: number
  escalatedTickets: number
  averageSatisfaction: number | null
  callsCount: number
  averageSentiment: number | null
  negativeCalls: number
  rivalMentions: number
  cancelIntentCalls: number
  drivers: string[]
  actionId: string | null
  actionChannel: string | null
  actionReason: string | null
  draftMessage: string | null
}
