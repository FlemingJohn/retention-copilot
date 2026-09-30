import 'server-only'
import { customerSummaryColumns } from '@/lib/queries/customerSummaryColumns'
import { mapCustomerSummary } from '@/lib/queries/mapCustomerSummary'
import { runStatement } from '@/lib/snowflake/runStatement'
import type { CustomerSummary } from '@/types/CustomerSummary'
import type { RiskTier } from '@/types/RiskTier'

const searchCondition = '(upper(customer_id) like ? or upper(first_name) like ? or upper(city) like ?)'

export async function listCustomers(search: string, tier: RiskTier | null, limit: number): Promise<CustomerSummary[]> {
  const conditions: string[] = []
  const values: string[] = []
  if (search !== '') {
    const pattern = `%${search.toUpperCase()}%`
    conditions.push(searchCondition)
    values.push(pattern, pattern, pattern)
  }
  if (tier !== null) {
    conditions.push('risk_tier = ?')
    values.push(tier)
  }
  const whereClause = conditions.length > 0 ? `where ${conditions.join(' and ')}` : ''
  const rows = await runStatement(
    `select ${customerSummaryColumns} from CUSTOMER_OVERVIEW ${whereClause}
     order by priority_rank asc nulls last, churn_probability desc
     limit ${Math.trunc(limit)}`,
    values,
  )
  return rows.map(mapCustomerSummary)
}
