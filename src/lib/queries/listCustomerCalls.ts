import 'server-only'
import { mapCall } from '@/lib/queries/mapCall'
import { runStatement } from '@/lib/snowflake/runStatement'
import type { CallSummary } from '@/types/CallSummary'

const callsStatement = `
  select transcript_id, customer_id, call_at, sentiment_score, main_topic,
         competitor_mentioned, complaint_reason, wants_to_cancel, transcript_text
  from CALL_OVERVIEW
  where customer_id = ?
  order by call_at desc`

export async function listCustomerCalls(customerId: string): Promise<CallSummary[]> {
  const rows = await runStatement(callsStatement, [customerId])
  return rows.map(mapCall)
}
