import type { ActionConfidence } from '@/types/ActionConfidence'
import type { ActionStatus } from '@/types/ActionStatus'
import type { RiskTier } from '@/types/RiskTier'

export interface CustomerSummary {
  customerId: string
  firstName: string
  city: string
  segment: string
  riskTier: RiskTier
  churnProbability: number
  actionType: string | null
  actionConfidence: ActionConfidence | null
  actionStatus: ActionStatus | null
  priorityRank: number | null
  revenueAtRisk: number | null
}
