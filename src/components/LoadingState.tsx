import styles from '@/components/StateMessage.module.css'

export default function LoadingState({ label = 'Loading' }: { label?: string }) {
  return (
    <div className={styles.message} role="status">
      {label}...
    </div>
  )
}
