import styles from '@/components/SummaryTile.module.css'

export default function SummaryTile({ label, value, note }: { label: string; value: string; note?: string }) {
  return (
    <div className={styles.tile}>
      <span className={styles.label}>{label}</span>
      <span className={styles.value}>{value}</span>
      {note ? <span className={styles.note}>{note}</span> : null}
    </div>
  )
}
