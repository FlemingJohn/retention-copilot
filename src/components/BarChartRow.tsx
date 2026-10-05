import { chartLayout } from '@/lib/chat/chartLayout'
import { formatChartValue } from '@/lib/format/formatChartValue'
import styles from '@/components/BarChart.module.css'
import type { ChartUnit } from '@/types/ChartUnit'

const barAreaWidth = chartLayout.width - chartLayout.labelWidth - chartLayout.valueWidth

function shorten(label: string): string {
  return label.length > chartLayout.longestLabel ? `${label.slice(0, chartLayout.longestLabel - 1)}…` : label
}

export default function BarChartRow({
  label,
  value,
  largest,
  index,
  unit,
}: {
  label: string
  value: number
  largest: number
  index: number
  unit: ChartUnit
}) {
  const top = index * chartLayout.rowHeight
  const middle = top + chartLayout.rowHeight / 2
  const barTop = middle - chartLayout.barHeight / 2
  const barWidth = Math.max(4, (Math.abs(value) / largest) * barAreaWidth)
  return (
    <g>
      <text x={0} y={middle} dominantBaseline="middle" className={styles.label}>
        {shorten(label)}
      </text>
      <rect x={chartLayout.labelWidth} y={barTop} width={barAreaWidth} height={chartLayout.barHeight} rx={7} className={styles.track} />
      <rect x={chartLayout.labelWidth} y={barTop} width={barWidth} height={chartLayout.barHeight} rx={7} className={styles.bar} />
      <text x={chartLayout.width} y={middle} dominantBaseline="middle" textAnchor="end" className={styles.value}>
        {formatChartValue(value, unit)}
      </text>
    </g>
  )
}
