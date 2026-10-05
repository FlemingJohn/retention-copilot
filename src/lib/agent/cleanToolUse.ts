import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { JsonObject } from '@/types/JsonObject'

const longestDetail = 600
const detailFields = ['query', 'sql', 'pruning_question']

function readDetail(input: JsonObject): string {
  const field = detailFields.find((name) => typeof input[name] === 'string')
  return field === undefined ? '' : String(input[field]).slice(0, longestDetail)
}

export function cleanToolUse(data: JsonObject): AgentStreamEvent | null {
  if (typeof data.name !== 'string' || typeof data.tool_use_id !== 'string') {
    return null
  }
  const input = (data.input ?? {}) as JsonObject
  return { type: 'tool', id: data.tool_use_id, name: data.name, detail: readDetail(input) }
}
