import 'server-only'
import { ServiceError } from '@/lib/errors/ServiceError'
import { readText } from '@/lib/queries/rowReaders'
import { runStatement } from '@/lib/snowflake/runStatement'
import type { ActionStatus } from '@/types/ActionStatus'
import type { DecisionResult } from '@/types/DecisionResult'

function readOutcomeMessage(outcome: Record<string, unknown> | undefined): string {
  return String(Object.values(outcome ?? {})[0] ?? '')
}

function rejectFailedOutcome(message: string): void {
  if (message.startsWith('No such action')) {
    throw new ServiceError('That action does not exist', 404)
  }
  if (message.startsWith('Invalid decision')) {
    throw new ServiceError(message, 400)
  }
}

export async function recordDecision(actionId: string, decision: string, note: string): Promise<DecisionResult> {
  const [outcome] = await runStatement('call RECORD_ACTION_DECISION(?, ?, ?)', [actionId, decision, note])
  const message = readOutcomeMessage(outcome)
  rejectFailedOutcome(message)
  const [statusRow] = await runStatement('select action_status from CUSTOMER_OVERVIEW where action_id = ?', [actionId])
  return { message, newStatus: readText(statusRow, 'ACTION_STATUS') as ActionStatus }
}
