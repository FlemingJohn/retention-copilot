import Link from 'next/link'
import type { ReactNode } from 'react'
import styles from '@/components/NavigationItem.module.css'

export default function NavigationItem({
  href,
  label,
  icon,
  isActive,
}: {
  href: string
  label: string
  icon: ReactNode
  isActive: boolean
}) {
  return (
    <Link
      href={href}
      title={label}
      aria-label={label}
      aria-current={isActive ? 'page' : undefined}
      className={`${styles.item} ${isActive ? styles.active : ''}`}
    >
      {icon}
      <span className={styles.label}>{label}</span>
    </Link>
  )
}
