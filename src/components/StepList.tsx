import SpinnerIcon from '@/components/SpinnerIcon'
import StepRow from '@/components/StepRow'
import ThinkingPanel from '@/components/ThinkingPanel'
import styles from '@/components/StepList.module.css'
import type { ChatEntry } from '@/types/ChatEntry'

export default function StepList({ entry }: { entry: ChatEntry }) {
  const rows = entry.steps.map((step) => <StepRow key={step.id} step={step} />)
  if (entry.isFinished) {
    return rows.length === 0 ? null : (
      <details className={styles.summary}>
        <summary>
          {rows.length} {rows.length === 1 ? 'step' : 'steps'} taken
        </summary>
        <ul className={styles.list}>{rows}</ul>
        <ThinkingPanel text={entry.thinking} />
      </details>
    )
  }
  return (
    <div className={styles.panel}>
      {rows.length > 0 ? <ul className={styles.list}>{rows}</ul> : null}
      <p className={styles.status}>
        <SpinnerIcon size={16} />
        {entry.status === '' ? 'Working' : entry.status}
      </p>
      <ThinkingPanel text={entry.thinking} />
    </div>
  )
}
