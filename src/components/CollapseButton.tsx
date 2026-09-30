import ChevronIcon from '@/components/ChevronIcon'
import styles from '@/components/CollapseButton.module.css'

export default function CollapseButton({ isCollapsed, onToggle }: { isCollapsed: boolean; onToggle: () => void }) {
  const label = isCollapsed ? 'Expand side panel' : 'Collapse side panel'
  return (
    <button
      type="button"
      className={`${styles.button} ${isCollapsed ? styles.collapsed : ''}`}
      onClick={onToggle}
      aria-expanded={!isCollapsed}
      aria-label={label}
      title={label}
    >
      <ChevronIcon size={20} />
      <span className={styles.label}>Collapse</span>
    </button>
  )
}
