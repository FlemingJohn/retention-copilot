import { runAgent } from '@/lib/agent/runAgent'
import { errorResponse } from '@/lib/http/errorResponse'
import { failValidation } from '@/lib/validation/failValidation'
import { parseMessages } from '@/lib/validation/parseMessages'

export const dynamic = 'force-dynamic'

async function readJsonBody(request: Request): Promise<{ messages?: unknown }> {
  try {
    return (await request.json()) as { messages?: unknown }
  } catch {
    return failValidation('Send a JSON body with a list of messages')
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const body = await readJsonBody(request)
    const stream = await runAgent(parseMessages(body.messages))
    return new Response(stream, {
      headers: { 'Content-Type': 'application/x-ndjson; charset=utf-8', 'Cache-Control': 'no-store' },
    })
  } catch (error) {
    return errorResponse(error)
  }
}
