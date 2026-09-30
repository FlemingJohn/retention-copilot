import type { AgentStreamEvent } from '@/types/AgentStreamEvent'

type EventData = Record<string, unknown>

interface ResultSet {
  data?: string[][]
  resultSetMetaData?: { rowType?: Array<{ name: string }> }
}

const largestTable = 50

function cleanTable(data: EventData): AgentStreamEvent | null {
  const resultSet = data.result_set as ResultSet | undefined
  const columns = resultSet?.resultSetMetaData?.rowType?.map((column) => column.name) ?? []
  if (columns.length === 0) {
    return null
  }
  const rows = (resultSet?.data ?? []).slice(0, largestTable)
  return { type: 'table', table: { title: String(data.title ?? ''), columns, rows } }
}

export function cleanAgentEvent(eventName: string, dataText: string): AgentStreamEvent | null {
  let data: EventData
  try {
    data = JSON.parse(dataText) as EventData
  } catch {
    return null
  }
  switch (eventName) {
    case 'response.text.delta':
      return typeof data.text === 'string' ? { type: 'text', text: data.text } : null
    case 'response.tool_use':
      return typeof data.name === 'string' ? { type: 'tool', name: data.name } : null
    case 'response.table':
      return cleanTable(data)
    case 'error':
      return { type: 'error', message: 'The assistant could not finish that request' }
    default:
      return null
  }
}
