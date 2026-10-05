import BarChartRow from '@/components/BarChartRow'
import { chartLayout } from '@/lib/chat/chartLayout'
import styles from '@/components/BarChart.module.css'
import type { AgentChart } from '@/types/AgentChart'

export default function BarChart({ chart }: { chart: AgentChart }) {
  const largest = Math.max(...chart.values.map((value) => Math.abs(value)), 1)
  const height = chart.labels.length * chartLayout.rowHeight
  return (
    <figure className={styles.figure}>
      {chart.title !== '' ? <figcaption className={styles.title}>{chart.title}</figcaption> : null}
      <svg
        viewBox={`0 0 ${chartLayout.width} ${height}`}
        className={styles.svg}
        role="img"
        aria-label={chart.title === '' ? 'Bar chart' : chart.title}
      >
        {chart.labels.map((label, index) => (
          <BarChartRow
            key={`${label}-${index}`}
            label={label}
            value={chart.values[index]}
            largest={largest}
            index={index}
            unit={chart.unit}
          />
        ))}
      </svg>
    </figure>
  )
}
