import type { ReactNode } from 'react'
import styles from '@/components/Card.module.css'

export default function Card({ title, children }: { title?: string; children: ReactNode }) {
  return (
    <section className={styles.card}>
      {title ? <h3 className={styles.title}>{title}</h3> : null}
      {children}
    </section>
  )
}
