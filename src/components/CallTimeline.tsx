import CallCard from '@/components/CallCard'
import Card from '@/components/Card'
import EmptyState from '@/components/EmptyState'
import styles from '@/components/CallTimeline.module.css'
import type { CallSummary } from '@/types/CallSummary'

export default function CallTimeline({ calls }: { calls: CallSummary[] }) {
  return (
    <Card title="Call timeline">
      {calls.length === 0 ? (
        <EmptyState message="This customer has no calls on record." />
      ) : (
        <div className={styles.list}>
          {calls.map((call) => (
            <CallCard key={call.transcriptId} call={call} />
          ))}
        </div>
      )}
    </Card>
  )
}
