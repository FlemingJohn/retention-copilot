import Link from 'next/link'
import MarkIcon from '@/components/MarkIcon'
import styles from '@/components/BrandMark.module.css'

export default function BrandMark() {
  return (
    <Link href="/" className={styles.brand}>
      <span className={styles.mark}>
        <MarkIcon size={20} />
      </span>
      <span className={styles.name}>Retention Copilot</span>
    </Link>
  )
}
