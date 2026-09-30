import { formatPercent } from '@/lib/format/formatPercent'
import styles from '@/components/SegmentBar.module.css'
import type { SegmentShare } from '@/types/SegmentShare'

export default function SegmentBar({ share }: { share: SegmentShare }) {
  const width = `${Math.max(2, Math.round(share.highRiskShare * 100))}%`
  return (
    <div className={styles.row}>
      <span>{share.segment}</span>
      <div className={styles.track} role="img" aria-label={`${share.segment}: ${formatPercent(share.highRiskShare)} high risk`}>
        <div className={styles.fill} style={{ width }} />
      </div>
      <span className={styles.figure}>{formatPercent(share.highRiskShare)}</span>
    </div>
  )
}
