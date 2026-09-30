import { readNullableNumber, readNullableText, readNumber, readText } from '@/lib/queries/rowReaders'
import type { ActionConfidence } from '@/types/ActionConfidence'
import type { ActionStatus } from '@/types/ActionStatus'
import type { CustomerSummary } from '@/types/CustomerSummary'
import type { RiskTier } from '@/types/RiskTier'
import type { SnowflakeRow } from '@/types/SnowflakeRow'

export function mapCustomerSummary(row: SnowflakeRow): CustomerSummary {
  return {
    customerId: readText(row, 'CUSTOMER_ID'),
    firstName: readText(row, 'FIRST_NAME'),
    city: readText(row, 'CITY'),
    segment: readText(row, 'SEGMENT'),
    riskTier: readText(row, 'RISK_TIER') as RiskTier,
    churnProbability: readNumber(row, 'CHURN_PROBABILITY'),
    actionType: readNullableText(row, 'ACTION_TYPE'),
    actionConfidence: readNullableText(row, 'ACTION_CONFIDENCE') as ActionConfidence | null,
    actionStatus: readNullableText(row, 'ACTION_STATUS') as ActionStatus | null,
    priorityRank: readNullableNumber(row, 'PRIORITY_RANK'),
    revenueAtRisk: readNullableNumber(row, 'REVENUE_AT_RISK'),
  }
}
