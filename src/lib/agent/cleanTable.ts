import type { AgentResultSet } from '@/types/AgentResultSet'
import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { JsonObject } from '@/types/JsonObject'

const largestTable = 50

export function cleanTable(data: JsonObject): AgentStreamEvent | null {
  const resultSet = data.result_set as AgentResultSet | undefined
  const columns = resultSet?.resultSetMetaData?.rowType?.map((column) => column.name) ?? []
  if (columns.length === 0) {
    return null
  }
  const rows = (resultSet?.data ?? []).slice(0, largestTable)
  return { type: 'table', table: { title: String(data.title ?? ''), columns, rows } }
}
