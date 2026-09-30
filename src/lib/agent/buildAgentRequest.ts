import 'server-only'
import { readConfiguration } from '@/lib/config/readConfiguration'
import { buildRequestHeaders } from '@/lib/snowflake/buildRequestHeaders'
import type { ConversationMessage } from '@/types/ConversationMessage'

function toAgentMessage(message: ConversationMessage) {
  return { role: message.role, content: [{ type: 'text', text: message.text }] }
}

export function buildAgentRequest(messages: ConversationMessage[]): { url: string; init: RequestInit } {
  const configuration = readConfiguration()
  const url = [
    configuration.accountUrl,
    '/api/v2/databases/',
    configuration.database,
    '/schemas/',
    configuration.schema,
    '/agents/',
    configuration.agentName,
    ':run',
  ].join('')
  return {
    url,
    init: {
      method: 'POST',
      headers: buildRequestHeaders(configuration.token, 'text/event-stream'),
      cache: 'no-store',
      body: JSON.stringify({ messages: messages.map(toAgentMessage) }),
    },
  }
}
