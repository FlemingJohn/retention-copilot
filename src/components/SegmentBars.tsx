import Card from '@/components/Card'
import SegmentBar from '@/components/SegmentBar'
import styles from '@/components/SegmentBars.module.css'
import type { SegmentShare } from '@/types/SegmentShare'

export default function SegmentBars({ shares }: { shares: SegmentShare[] }) {
  return (
    <Card title="Share of customers at high risk, by segment">
      <div className={styles.list}>
        {shares.map((share) => (
          <SegmentBar key={share.segment} share={share} />
        ))}
      </div>
    </Card>
  )
}
