import styles from '@/components/DriverList.module.css'

export default function DriverList({ drivers }: { drivers: string[] }) {
  if (drivers.length === 0) {
    return <p className={styles.empty}>No strong warning signs.</p>
  }
  return (
    <ul className={styles.list}>
      {drivers.map((driver) => (
        <li key={driver}>{driver}</li>
      ))}
    </ul>
  )
}
