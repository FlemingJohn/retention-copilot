import SummaryTile from '@/components/SummaryTile'
import { formatRupees } from '@/lib/format/formatRupees'
import styles from '@/components/SummaryTiles.module.css'
import type { OverviewSummary } from '@/types/OverviewSummary'

export default function SummaryTiles({ summary }: { summary: OverviewSummary }) {
  return (
    <div className={styles.grid}>
      <SummaryTile label="Customers at risk" value={summary.customersAtRisk.toLocaleString('en-IN')} note="High and Medium" />
      <SummaryTile label="High risk customers" value={summary.highRiskCustomers.toLocaleString('en-IN')} />
      <SummaryTile label="Expected revenue at risk" value={formatRupees(summary.revenueAtRisk)} note="Annual premium" />
      <SummaryTile label="Actions waiting" value={summary.actionsWaiting.toLocaleString('en-IN')} note="Pending or needs review" />
    </div>
  )
}
