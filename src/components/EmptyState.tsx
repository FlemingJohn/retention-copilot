import styles from '@/components/StateMessage.module.css'

export default function EmptyState({ message }: { message: string }) {
  return <div className={styles.message}>{message}</div>
}
