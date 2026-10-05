import TranscriptIcon from '@/components/TranscriptIcon'
import styles from '@/components/SourceList.module.css'

export default function SourceList({ sources }: { sources: string[] }) {
  return (
    <details className={styles.sources}>
      <summary className={styles.summary}>
        <TranscriptIcon size={16} />
        Heard on {sources.length === 1 ? 'a call' : `${sources.length} calls`}
      </summary>
      <div className={styles.list}>
        {sources.map((source) => (
          <blockquote key={source} className={styles.quote}>
            {source}
          </blockquote>
        ))}
      </div>
    </details>
  )
}
