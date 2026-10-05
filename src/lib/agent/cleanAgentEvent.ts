import { cleanChart } from '@/lib/agent/cleanChart'
import { cleanSource } from '@/lib/agent/cleanSource'
import { cleanSuggestions } from '@/lib/agent/cleanSuggestions'
import { cleanTable } from '@/lib/agent/cleanTable'
import { cleanToolUse } from '@/lib/agent/cleanToolUse'
import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { JsonObject } from '@/types/JsonObject'

function readText(data: JsonObject, type: 'text' | 'thinking'): AgentStreamEvent | null {
  return typeof data.text === 'string' ? { type, text: data.text } : null
}

function readChart(data: JsonObject): AgentStreamEvent | null {
  const chart = typeof data.chart_spec === 'string' ? cleanChart(data.chart_spec) : null
  return chart === null ? null : { type: 'chart', chart }
}

function readStatus(data: JsonObject): AgentStreamEvent | null {
  return typeof data.message === 'string' ? { type: 'status', message: data.message } : null
}

function readToolDone(data: JsonObject): AgentStreamEvent | null {
  return typeof data.tool_use_id === 'string' ? { type: 'toolDone', id: data.tool_use_id } : null
}

export function cleanAgentEvent(eventName: string, dataText: string): AgentStreamEvent | null {
  let data: JsonObject
  try {
    data = JSON.parse(dataText) as JsonObject
  } catch {
    return null
  }
  switch (eventName) {
    case 'response.text.delta':
      return readText(data, 'text')
    case 'response.thinking.delta':
      return readText(data, 'thinking')
    case 'response.status':
      return readStatus(data)
    case 'response.tool_use':
      return cleanToolUse(data)
    case 'response.tool_result':
      return readToolDone(data)
    case 'response.table':
      return cleanTable(data)
    case 'response.chart':
      return readChart(data)
    case 'response.text.annotation':
      return cleanSource(data)
    case 'response.suggested_queries':
      return cleanSuggestions(data)
    case 'error':
      return { type: 'error', message: 'The assistant could not finish that request' }
    default:
      return null
  }
}
