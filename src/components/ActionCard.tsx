import Card from '@/components/Card'
import ConfidenceChip from '@/components/ConfidenceChip'
import DecisionPanel from '@/components/DecisionPanel'
import DraftMessage from '@/components/DraftMessage'
import EmptyState from '@/components/EmptyState'
import StatusChip from '@/components/StatusChip'
import styles from '@/components/ActionCard.module.css'
import type { ActionStatus } from '@/types/ActionStatus'
import type { CustomerProfile } from '@/types/CustomerProfile'

export default function ActionCard({
  profile,
  onDecided,
}: {
  profile: CustomerProfile
  onDecided: (newStatus: ActionStatus) => void
}) {
  if (profile.actionId === null) {
    return (
      <Card title="Recommended action">
        <EmptyState message="No action is recommended for this customer." />
      </Card>
    )
  }
  return (
    <Card title="Recommended action">
      <div className={styles.heading}>
        <h2>{profile.actionType}</h2>
        <StatusChip status={profile.actionStatus} />
      </div>
      <div className={styles.meta}>
        <ConfidenceChip confidence={profile.actionConfidence} />
        <span>By {profile.actionChannel?.toLowerCase()}</span>
      </div>
      {profile.actionReason ? <p className={styles.reason}>{profile.actionReason}</p> : null}
      {profile.actionConfidence === 'Low' ? (
        <p className={styles.warning}>Low confidence. A person should review this before anything is sent.</p>
      ) : null}
      {profile.draftMessage ? <DraftMessage text={profile.draftMessage} /> : null}
      <DecisionPanel actionId={profile.actionId} onDecided={onDecided} />
    </Card>
  )
}
