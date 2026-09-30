import 'server-only'
import type { SnowflakeColumn } from '@/types/SnowflakeColumn'

const millisecondsPerDay = 86_400_000

function toIsoTimestamp(seconds: string): string {
  return new Date(Number(seconds.split(' ')[0]) * 1000).toISOString()
}

export function convertCell(column: SnowflakeColumn, cell: string | null): string | number | boolean | null {
  if (cell === null) {
    return null
  }
  switch (column.type) {
    case 'fixed':
    case 'real':
      return Number(cell)
    case 'boolean':
      return cell === 'true' || cell === '1'
    case 'date':
      return new Date(Number(cell) * millisecondsPerDay).toISOString().slice(0, 10)
    case 'timestamp_ntz':
    case 'timestamp_ltz':
    case 'timestamp_tz':
      return toIsoTimestamp(cell)
    default:
      return cell
  }
}
