import Button from '@/components/Button'
import styles from '@/components/StateMessage.module.css'

export default function ErrorMessage({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className={`${styles.message} ${styles.error}`} role="alert">
      <span>{message}</span>
      {onRetry ? (
        <Button variant="secondary" onClick={onRetry}>
          Try again
        </Button>
      ) : null}
    </div>
  )
}
