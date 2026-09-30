import Card from '@/components/Card'
import DriverList from '@/components/DriverList'
import RiskChip from '@/components/RiskChip'
import { formatRupees } from '@/lib/format/formatRupees'
import styles from '@/components/RiskCard.module.css'
import type { CustomerProfile } from '@/types/CustomerProfile'

export default function RiskCard({ profile }: { profile: CustomerProfile }) {
  return (
    <Card title="Churn risk">
      <div className={styles.summary}>
        <RiskChip tier={profile.riskTier} probability={profile.churnProbability} />
        <span className={styles.note}>modelled chance of cancelling within 90 days</span>
      </div>
      <h3>What is driving it</h3>
      <DriverList drivers={profile.drivers} />
      {profile.revenueAtRisk !== null ? (
        <p className={styles.note}>Expected annual premium at risk: {formatRupees(profile.revenueAtRisk)}</p>
      ) : null}
    </Card>
  )
}
