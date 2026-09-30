import styles from '@/components/TierFilter.module.css'
import type { RiskTier } from '@/types/RiskTier'

export default function TierFilter({
  options,
  selected,
  onSelect,
}: {
  options: Array<RiskTier | null>
  selected: RiskTier | null
  onSelect: (tier: RiskTier | null) => void
}) {
  return (
    <div className={styles.group} role="group" aria-label="Filter by risk">
      {options.map((option) => (
        <button
          key={option ?? 'All'}
          type="button"
          className={`${styles.option} ${option === selected ? styles.selected : ''}`}
          aria-pressed={option === selected}
          onClick={() => onSelect(option)}
        >
          {option ?? 'All'}
        </button>
      ))}
    </div>
  )
}
