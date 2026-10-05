import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { JsonObject } from '@/types/JsonObject'

const longestSource = 240

export function cleanSource(data: JsonObject): AgentStreamEvent | null {
  const annotation = data.annotation as JsonObject | undefined
  if (typeof annotation?.text !== 'string' || annotation.text.trim() === '') {
    return null
  }
  return { type: 'source', text: annotation.text.trim().slice(0, longestSource) }
}
