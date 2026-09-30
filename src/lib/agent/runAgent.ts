import 'server-only'
import { buildAgentRequest } from '@/lib/agent/buildAgentRequest'
import { streamAgentEvents } from '@/lib/agent/streamAgentEvents'
import { ServiceError } from '@/lib/errors/ServiceError'
import type { ConversationMessage } from '@/types/ConversationMessage'

export async function runAgent(messages: ConversationMessage[]): Promise<ReadableStream<Uint8Array>> {
  const { url, init } = buildAgentRequest(messages)
  const response = await fetch(url, init)
  if (!response.ok || response.body === null) {
    console.error('Assistant request failed with status', response.status)
    throw new ServiceError('The assistant is unavailable right now', 502)
  }
  return streamAgentEvents(response.body)
}
