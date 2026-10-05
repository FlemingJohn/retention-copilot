import Link from 'next/link'
import { formatPercent } from '@/lib/format/formatPercent'
import { formatRupees } from '@/lib/format/formatRupees'
import styles from '@/components/CustomerCard.module.css'
import type { CustomerMention } from '@/types/CustomerMention'

export default function CustomerCard({ mention }: { mention: CustomerMention }) {
  return (
    <Link href={`/customers/${mention.customerId}`} className={styles.card}>
      <span className={styles.name}>{mention.firstName ?? mention.customerId}</span>
      <span className={styles.place}>
        {mention.customerId}
        {mention.city !== null ? ` · ${mention.city}` : ''}
      </span>
      {mention.actionType !== null ? <span className={styles.action}>{mention.actionType}</span> : null}
      <span className={styles.numbers}>
        {mention.churnProbability !== null ? <span>{formatPercent(mention.churnProbability)} churn risk</span> : null}
        {mention.revenueAtRisk !== null ? <span>{formatRupees(mention.revenueAtRisk)} at risk</span> : null}
      </span>
    </Link>
  )
}
