import type { ChartUnit } from '@/types/ChartUnit'

const rupeeHints = ['revenue', 'premium', 'amount', 'rupee']

export function readChartUnit(fieldName: string): ChartUnit {
  const name = fieldName.toLowerCase()
  return rupeeHints.some((hint) => name.includes(hint)) ? 'rupees' : 'number'
}
