import styles from '@/components/CallCard.module.css'
import chipStyles from '@/components/Chip.module.css'
import { describeSentiment } from '@/lib/format/describeSentiment'
import { formatDate } from '@/lib/format/formatDate'
import type { CallSummary } from '@/types/CallSummary'

const toneBySentiment = {
  Negative: chipStyles.danger,
  Neutral: chipStyles.quiet,
  Positive: chipStyles.success,
}

export default function CallCard({ call }: { call: CallSummary }) {
  const sentiment = describeSentiment(call.sentimentScore)
  return (
    <article className={styles.card}>
      <div className={styles.heading}>
        <strong>{formatDate(call.callAt)}</strong>
        <span className={styles.topic}>{call.mainTopic ?? 'Topic not identified'}</span>
        {sentiment !== null ? (
          <span className={`${chipStyles.chip} ${toneBySentiment[sentiment]}`}>{sentiment} call</span>
        ) : null}
        {call.competitorMentioned !== null ? (
          <span className={`${chipStyles.chip} ${chipStyles.warning}`}>Mentioned {call.competitorMentioned}</span>
        ) : null}
      </div>
      {call.complaintReason !== null ? <p className={styles.reason}>{call.complaintReason}</p> : null}
      <details className={styles.details}>
        <summary>Read the transcript</summary>
        <p className={styles.transcript}>{call.transcriptText}</p>
      </details>
    </article>
  )
}
