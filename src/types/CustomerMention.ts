export interface CustomerMention {
  customerId: string
  firstName: string | null
  city: string | null
  actionType: string | null
  churnProbability: number | null
  revenueAtRisk: number | null
}
