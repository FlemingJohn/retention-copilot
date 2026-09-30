import type { SnowflakeRow } from '@/types/SnowflakeRow'

export function readText(row: SnowflakeRow, key: string): string {
  return String(row[key] ?? '')
}

export function readNullableText(row: SnowflakeRow, key: string): string | null {
  const value = row[key]
  return value === null || value === undefined || value === '' ? null : String(value)
}

export function readNumber(row: SnowflakeRow, key: string): number {
  return Number(row[key] ?? 0)
}

export function readNullableNumber(row: SnowflakeRow, key: string): number | null {
  const value = row[key]
  return value === null || value === undefined ? null : Number(value)
}

export function readNullableBoolean(row: SnowflakeRow, key: string): boolean | null {
  const value = row[key]
  return value === null || value === undefined ? null : Boolean(value)
}
