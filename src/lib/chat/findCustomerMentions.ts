import type { AgentTable } from '@/types/AgentTable'
import type { CustomerMention } from '@/types/CustomerMention'

const mostMentions = 6

function readNumber(value: string | undefined): number | null {
  const number = Number(value)
  return value === undefined || value === '' || !Number.isFinite(number) ? null : number
}

function readText(value: string | undefined): string | null {
  return value === undefined || value === '' ? null : value
}

export function findCustomerMentions(table: AgentTable | null): CustomerMention[] {
  if (table === null) {
    return []
  }
  const names = table.columns.map((column) => column.toLowerCase())
  const idIndex = names.indexOf('customer_id')
  if (idIndex === -1) {
    return []
  }
  const cell = (row: string[], name: string) => row[names.indexOf(name)]
  return table.rows.slice(0, mostMentions).map((row) => ({
    customerId: row[idIndex],
    firstName: readText(cell(row, 'first_name')),
    city: readText(cell(row, 'city')),
    actionType: readText(cell(row, 'action_type')),
    churnProbability: readNumber(cell(row, 'churn_probability')),
    revenueAtRisk: readNumber(cell(row, 'revenue_at_risk')),
  }))
}
