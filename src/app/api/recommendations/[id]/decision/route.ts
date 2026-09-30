import { errorResponse } from '@/lib/http/errorResponse'
import { jsonResponse } from '@/lib/http/jsonResponse'
import { recordDecision } from '@/lib/queries/recordDecision'
import { failValidation } from '@/lib/validation/failValidation'
import { parseActionId } from '@/lib/validation/parseActionId'
import { parseDecision } from '@/lib/validation/parseDecision'
import { parseNote } from '@/lib/validation/parseNote'

export const dynamic = 'force-dynamic'

async function readJsonBody(request: Request): Promise<{ decision?: unknown; note?: unknown }> {
  try {
    return (await request.json()) as { decision?: unknown; note?: unknown }
  } catch {
    return failValidation('Send a JSON body with a decision and an optional note')
  }
}

export async function POST(request: Request, context: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const actionId = parseActionId((await context.params).id)
    const body = await readJsonBody(request)
    const decision = parseDecision(body.decision)
    const note = parseNote(body.note)
    return jsonResponse(await recordDecision(actionId, decision, note))
  } catch (error) {
    return errorResponse(error)
  }
}
