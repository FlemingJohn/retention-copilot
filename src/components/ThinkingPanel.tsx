import ThinkingIcon from '@/components/ThinkingIcon'
import styles from '@/components/ThinkingPanel.module.css'

export default function ThinkingPanel({ text }: { text: string }) {
  if (text.trim() === '') {
    return null
  }
  return (
    <details className={styles.panel}>
      <summary className={styles.summary}>
        <ThinkingIcon size={16} />
        Reasoning
      </summary>
      <p className={styles.text}>{text.trim()}</p>
    </details>
  )
}
