import AlertIcon from '@/components/AlertIcon'
import CheckIcon from '@/components/CheckIcon'
import styles from '@/components/Chip.module.css'
import { formatPercent } from '@/lib/format/formatPercent'
import type { RiskTier } from '@/types/RiskTier'

const toneByTier: Record<RiskTier, string> = {
  High: styles.danger,
  Medium: styles.warning,
  Low: styles.success,
}

export default function RiskChip({ tier, probability }: { tier: RiskTier; probability: number }) {
  return (
    <span className={`${styles.chip} ${toneByTier[tier]}`}>
      {tier === 'Low' ? <CheckIcon size={12} /> : <AlertIcon size={12} />}
      {tier} {formatPercent(probability)}
    </span>
  )
}
