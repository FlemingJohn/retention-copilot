import 'server-only'
import { convertCell } from '@/lib/snowflake/convertCell'
import type { SnowflakeColumn } from '@/types/SnowflakeColumn'
import type { SnowflakeRow } from '@/types/SnowflakeRow'

export function mapRows(columns: SnowflakeColumn[], rows: Array<Array<string | null>>): SnowflakeRow[] {
  return rows.map((cells) => {
    const row: SnowflakeRow = {}
    columns.forEach((column, index) => {
      row[column.name] = convertCell(column, cells[index] ?? null)
    })
    return row
  })
}
