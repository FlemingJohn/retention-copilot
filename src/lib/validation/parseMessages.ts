import { failValidation } from '@/lib/validation/failValidation'
import type { ConversationMessage } from '@/types/ConversationMessage'

const mostMessages = 20
const longestUserText = 500
const longestAssistantText = 4000

function parseMessage(value: unknown): ConversationMessage {
  const candidate = value as { role?: unknown; text?: unknown }
  if (candidate?.role !== 'user' && candidate?.role !== 'assistant') {
    failValidation('Each message needs a role of user or assistant')
  }
  if (typeof candidate.text !== 'string' || candidate.text.trim() === '') {
    failValidation('Each message needs some text')
  }
  const limit = candidate.role === 'user' ? longestUserText : longestAssistantText
  if ((candidate.text as string).length > limit) {
    failValidation('A message is too long')
  }
  return { role: candidate.role as 'user' | 'assistant', text: (candidate.text as string).trim() }
}

export function parseMessages(value: unknown): ConversationMessage[] {
  if (!Array.isArray(value) || value.length === 0 || value.length > mostMessages) {
    failValidation(`Send between 1 and ${mostMessages} messages`)
  }
  const messages = (value as unknown[]).map(parseMessage)
  if (messages[messages.length - 1].role !== 'user') {
    failValidation('The last message must be from the user')
  }
  return messages
}
