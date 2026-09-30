import ResultTable from '@/components/ResultTable'
import ToolChip from '@/components/ToolChip'
import styles from '@/components/ChatBubble.module.css'
import type { ChatEntry } from '@/types/ChatEntry'

export default function ChatBubble({ entry, isWaiting }: { entry: ChatEntry; isWaiting: boolean }) {
  if (entry.role === 'user') {
    return <div className={styles.user}>{entry.text}</div>
  }
  const isEmpty = entry.text === ''
  return (
    <div className={`${styles.assistant} ${entry.hasFailed ? styles.failed : ''}`}>
      {entry.tools.length > 0 ? (
        <div className={styles.tools}>
          {entry.tools.map((name) => (
            <ToolChip key={name} name={name} />
          ))}
        </div>
      ) : null}
      {isEmpty && isWaiting ? <p className={styles.waiting}>Working on it</p> : null}
      {isEmpty ? null : <p className={styles.text}>{entry.text}</p>}
      {entry.table !== null ? <ResultTable table={entry.table} /> : null}
    </div>
  )
}
