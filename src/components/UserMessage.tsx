import styles from '@/components/UserMessage.module.css'

export default function UserMessage({ text }: { text: string }) {
  return <div className={styles.message}>{text}</div>
}
