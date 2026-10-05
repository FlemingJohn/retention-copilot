import IconFrame from '@/components/IconFrame'
import styles from '@/components/SpinnerIcon.module.css'

export default function SpinnerIcon({ size }: { size?: number }) {
  return (
    <span className={styles.spinner} role="status" aria-label="Working">
      <IconFrame size={size}>
        <path d="M12 3.5a8.5 8.5 0 1 1-8.5 8.5" />
      </IconFrame>
    </span>
  )
}
