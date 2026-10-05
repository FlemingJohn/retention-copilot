import CustomerCard from '@/components/CustomerCard'
import styles from '@/components/CustomerCards.module.css'
import type { CustomerMention } from '@/types/CustomerMention'

export default function CustomerCards({ mentions }: { mentions: CustomerMention[] }) {
  return (
    <div className={styles.grid}>
      {mentions.map((mention) => (
        <CustomerCard key={mention.customerId} mention={mention} />
      ))}
    </div>
  )
}
