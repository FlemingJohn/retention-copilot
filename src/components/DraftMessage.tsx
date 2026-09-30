import styles from '@/components/DraftMessage.module.css'

export default function DraftMessage({ text }: { text: string }) {
  return (
    <div className={styles.box}>
      <span className={styles.label}>Draft for review</span>
      <p className={styles.text}>{text}</p>
    </div>
  )
}
