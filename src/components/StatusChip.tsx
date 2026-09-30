import styles from '@/components/Chip.module.css'
import type { ActionStatus } from '@/types/ActionStatus'

const toneByStatus: Record<ActionStatus, string> = {
  Pending: styles.accent,
  'Needs review': styles.warning,
  Approved: styles.success,
  Dismissed: styles.quiet,
}

export default function StatusChip({ status }: { status: ActionStatus | null }) {
  if (status === null) {
    return <span className={`${styles.chip} ${styles.quiet}`}>None</span>
  }
  return <span className={`${styles.chip} ${toneByStatus[status]}`}>{status}</span>
}
