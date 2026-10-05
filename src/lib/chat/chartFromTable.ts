import { readChartUnit } from '@/lib/chat/readChartUnit'
import type { AgentChart } from '@/types/AgentChart'
import type { AgentTable } from '@/types/AgentTable'

const fewestRows = 2
const mostRows = 12
const customerIdPattern = /^C\d{6}$/
const valueNameHints = ['revenue', 'count', 'total', 'amount', 'customers', 'number']

function isNumberColumn(rows: string[][], index: number): boolean {
  return rows.every((row) => row[index] !== '' && Number.isFinite(Number(row[index])))
}

function pickValueIndex(columns: string[], isNumber: boolean[]): number {
  const hinted = columns.findIndex(
    (column, index) => isNumber[index] && valueNameHints.some((hint) => column.toLowerCase().includes(hint)),
  )
  return hinted === -1 ? isNumber.indexOf(true) : hinted
}

function pickLabelIndex(rows: string[][], isNumber: boolean[]): number {
  return isNumber.findIndex((numeric, index) => !numeric && !rows.every((row) => customerIdPattern.test(row[index])))
}

function hasLabel(row: string[], labelIndex: number): boolean {
  const label = row[labelIndex]
  return label !== null && label !== undefined && label !== '' && label.toLowerCase() !== 'null'
}

export function chartFromTable(table: AgentTable | null): AgentChart | null {
  if (table === null || table.rows.length > mostRows) {
    return null
  }
  const isNumber = table.columns.map((_, index) => isNumberColumn(table.rows, index))
  const valueIndex = pickValueIndex(table.columns, isNumber)
  const labelIndex = pickLabelIndex(table.rows, isNumber)
  const rows = table.rows.filter((row) => hasLabel(row, labelIndex))
  if (valueIndex === -1 || labelIndex === -1 || rows.length < fewestRows) {
    return null
  }
  return {
    title: table.title,
    labels: rows.map((row) => row[labelIndex]),
    values: rows.map((row) => Number(row[valueIndex])),
    unit: readChartUnit(table.columns[valueIndex]),
  }
}
