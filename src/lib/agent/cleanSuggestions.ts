import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { JsonObject } from '@/types/JsonObject'

const mostSuggestions = 3

export function cleanSuggestions(data: JsonObject): AgentStreamEvent | null {
  const items = Array.isArray(data.suggested_queries) ? (data.suggested_queries as JsonObject[]) : []
  const questions = items
    .map((item) => item.query)
    .filter((query): query is string => typeof query === 'string' && query.trim() !== '')
    .slice(0, mostSuggestions)
  return questions.length === 0 ? null : { type: 'suggestions', questions }
}
