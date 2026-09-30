import Link from 'next/link'
import ConfidenceChip from '@/components/ConfidenceChip'
import RiskChip from '@/components/RiskChip'
import StatusChip from '@/components/StatusChip'
import { formatRupees } from '@/lib/format/formatRupees'
import styles from '@/components/CustomerTable.module.css'
import type { CustomerSummary } from '@/types/CustomerSummary'

export default function CustomerRow({ customer }: { customer: CustomerSummary }) {
  return (
    <tr>
      <td>
        <Link href={`/customers/${customer.customerId}`} className={styles.name}>
          {customer.firstName}
        </Link>
        <span className={styles.detail}>
          {customer.city} · {customer.customerId}
        </span>
      </td>
      <td>
        <RiskChip tier={customer.riskTier} probability={customer.churnProbability} />
      </td>
      <td>{customer.actionType ?? 'None needed'}</td>
      <td>
        <ConfidenceChip confidence={customer.actionConfidence} />
      </td>
      <td>
        <StatusChip status={customer.actionStatus} />
      </td>
      <td className={styles.number}>{formatRupees(customer.revenueAtRisk)}</td>
    </tr>
  )
}
