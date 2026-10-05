import type { ChartUnit } from '@/types/ChartUnit'

export interface AgentChart {
  title: string
  labels: string[]
  values: number[]
  unit: ChartUnit
}
