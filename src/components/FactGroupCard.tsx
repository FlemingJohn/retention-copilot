import Card from '@/components/Card'
import styles from '@/components/FactGroupCard.module.css'
import type { FactGroup } from '@/lib/profile/buildFactGroups'

export default function FactGroupCard({ group }: { group: FactGroup }) {
  return (
    <Card title={group.title}>
      <dl className={styles.list}>
        {group.facts.map((fact) => (
          <div key={fact.label} className={styles.row}>
            <dt>{fact.label}</dt>
            <dd>{fact.value}</dd>
          </div>
        ))}
      </dl>
    </Card>
  )
}
