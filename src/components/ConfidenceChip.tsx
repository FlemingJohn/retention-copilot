import styles from '@/components/Chip.module.css'
import type { ActionConfidence } from '@/types/ActionConfidence'

const toneByConfidence: Record<ActionConfidence, string> = {
  High: styles.success,
  Medium: styles.accent,
  Low: styles.warning,
}

export default function ConfidenceChip({ confidence }: { confidence: ActionConfidence | null }) {
  if (confidence === null) {
    return <span className={`${styles.chip} ${styles.quiet}`}>No action</span>
  }
  return <span className={`${styles.chip} ${toneByConfidence[confidence]}`}>{confidence} confidence</span>
}
