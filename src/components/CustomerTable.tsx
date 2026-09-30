import CustomerRow from '@/components/CustomerRow'
import EmptyState from '@/components/EmptyState'
import styles from '@/components/CustomerTable.module.css'
import type { CustomerSummary } from '@/types/CustomerSummary'

export default function CustomerTable({ customers }: { customers: CustomerSummary[] }) {
  if (customers.length === 0) {
    return <EmptyState message="No customers match this view." />
  }
  return (
    <div className={styles.wrapper}>
      <table className={styles.table}>
        <thead>
          <tr>
            <th>Customer</th>
            <th>Risk</th>
            <th>Recommended action</th>
            <th>Confidence</th>
            <th>Status</th>
            <th className={styles.number}>Revenue at risk</th>
          </tr>
        </thead>
        <tbody>
          {customers.map((customer) => (
            <CustomerRow key={customer.customerId} customer={customer} />
          ))}
        </tbody>
      </table>
    </div>
  )
}
