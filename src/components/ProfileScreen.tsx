'use client'

import ActionCard from '@/components/ActionCard'
import CallTimeline from '@/components/CallTimeline'
import ErrorMessage from '@/components/ErrorMessage'
import FactGroupCard from '@/components/FactGroupCard'
import LoadingState from '@/components/LoadingState'
import ProfileHeader from '@/components/ProfileHeader'
import RiskCard from '@/components/RiskCard'
import { useCustomerCalls } from '@/hooks/useCustomerCalls'
import { useCustomerProfile } from '@/hooks/useCustomerProfile'
import { buildFactGroups } from '@/lib/profile/buildFactGroups'
import styles from '@/components/ProfileScreen.module.css'
import type { ActionStatus } from '@/types/ActionStatus'

export default function ProfileScreen({ customerId }: { customerId: string }) {
  const { data: profile, setData, errorMessage, isLoading, reload } = useCustomerProfile(customerId)
  const { data: calls } = useCustomerCalls(customerId)

  if (isLoading && profile === null) {
    return <LoadingState label="Loading the customer" />
  }
  if (errorMessage !== null || profile === null) {
    return <ErrorMessage message={errorMessage ?? 'This customer is not available'} onRetry={reload} />
  }

  function updateStatus(newStatus: ActionStatus) {
    setData(profile === null ? null : { ...profile, actionStatus: newStatus })
  }

  return (
    <>
      <ProfileHeader profile={profile} />
      <div className={styles.columns}>
        <div className={styles.column}>
          {buildFactGroups(profile).map((group) => (
            <FactGroupCard key={group.title} group={group} />
          ))}
        </div>
        <div className={styles.column}>
          <RiskCard profile={profile} />
          <ActionCard profile={profile} onDecided={updateStatus} />
        </div>
      </div>
      <CallTimeline calls={calls ?? []} />
    </>
  )
}
