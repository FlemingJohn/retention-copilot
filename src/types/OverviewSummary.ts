import type { CustomerSummary } from '@/types/CustomerSummary'
import type { SegmentShare } from '@/types/SegmentShare'

export interface OverviewSummary {
  customersAtRisk: number
  highRiskCustomers: number
  revenueAtRisk: number
  actionsWaiting: number
  segmentShares: SegmentShare[]
  priorityRows: CustomerSummary[]
}
