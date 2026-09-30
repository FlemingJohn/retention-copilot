import 'server-only'
import { customerSummaryColumns } from '@/lib/queries/customerSummaryColumns'
import { mapCustomerSummary } from '@/lib/queries/mapCustomerSummary'
import { readNumber, readText } from '@/lib/queries/rowReaders'
import { runStatement } from '@/lib/snowflake/runStatement'
import type { OverviewSummary } from '@/types/OverviewSummary'
import type { SegmentShare } from '@/types/SegmentShare'
import type { SnowflakeRow } from '@/types/SnowflakeRow'

const tilesStatement = `
  select
    count_if(risk_tier in ('High', 'Medium')) as customers_at_risk,
    count_if(risk_tier = 'High') as high_risk_customers,
    coalesce(sum(revenue_at_risk), 0) as revenue_at_risk,
    count_if(action_status in ('Pending', 'Needs review')) as actions_waiting
  from CUSTOMER_OVERVIEW`

const segmentsStatement = `
  select
    segment,
    count(*) as customer_count,
    count_if(risk_tier = 'High') as high_risk_count
  from CUSTOMER_OVERVIEW
  group by segment
  order by customer_count desc`

const priorityStatement = `
  select ${customerSummaryColumns}
  from CUSTOMER_OVERVIEW
  where priority_rank is not null
  order by priority_rank asc
  limit 25`

function mapSegmentShare(row: SnowflakeRow): SegmentShare {
  const customerCount = readNumber(row, 'CUSTOMER_COUNT')
  const highRiskCount = readNumber(row, 'HIGH_RISK_COUNT')
  return {
    segment: readText(row, 'SEGMENT'),
    customerCount,
    highRiskCount,
    highRiskShare: customerCount === 0 ? 0 : highRiskCount / customerCount,
  }
}

export async function getOverview(): Promise<OverviewSummary> {
  const [tileRows, segmentRows, priorityRows] = await Promise.all([
    runStatement(tilesStatement),
    runStatement(segmentsStatement),
    runStatement(priorityStatement),
  ])
  const tiles = tileRows[0] ?? {}
  return {
    customersAtRisk: readNumber(tiles, 'CUSTOMERS_AT_RISK'),
    highRiskCustomers: readNumber(tiles, 'HIGH_RISK_CUSTOMERS'),
    revenueAtRisk: readNumber(tiles, 'REVENUE_AT_RISK'),
    actionsWaiting: readNumber(tiles, 'ACTIONS_WAITING'),
    segmentShares: segmentRows.map(mapSegmentShare),
    priorityRows: priorityRows.map(mapCustomerSummary),
  }
}
