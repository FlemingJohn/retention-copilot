import AskOrSearchBox from '@/components/AskOrSearchBox'
import BrandMark from '@/components/BrandMark'
import styles from '@/components/TopBar.module.css'

export default function TopBar() {
  return (
    <div className={styles.bar}>
      <BrandMark />
      <AskOrSearchBox />
      <span className={styles.role}>Manager</span>
    </div>
  )
}
