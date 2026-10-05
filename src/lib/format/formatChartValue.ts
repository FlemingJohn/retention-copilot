import { formatRupees } from '@/lib/format/formatRupees'
import type { ChartUnit } from '@/types/ChartUnit'

export function formatChartValue(value: number, unit: ChartUnit): string {
  if (unit === 'rupees') {
    return formatRupees(value)
  }
  return value.toLocaleString('en-IN', { maximumFractionDigits: 2 })
}
