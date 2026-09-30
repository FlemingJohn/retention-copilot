'use client'

import { useState } from 'react'
import CustomerTable from '@/components/CustomerTable'
import ErrorMessage from '@/components/ErrorMessage'
import LoadingState from '@/components/LoadingState'
import PageHeader from '@/components/PageHeader'
import SegmentBars from '@/components/SegmentBars'
import SummaryTiles from '@/components/SummaryTiles'
import TierFilter from '@/components/TierFilter'
import { useOverview } from '@/hooks/useOverview'
import styles from '@/components/OverviewScreen.module.css'
import type { RiskTier } from '@/types/RiskTier'

export default function OverviewScreen() {
  const { data, errorMessage, isLoading, reload } = useOverview()
  const [tier, setTier] = useState<RiskTier | null>(null)

  if (isLoading && data === null) {
    return <LoadingState label="Loading the overview" />
  }
  if (errorMessage !== null || data === null) {
    return <ErrorMessage message={errorMessage ?? 'The overview is not available'} onRetry={reload} />
  }
  const rows = tier === null ? data.priorityRows : data.priorityRows.filter((row) => row.riskTier === tier)
  return (
    <>
      <PageHeader title="Overview" subtitle="Who to contact first, and what to do about it" />
      <SummaryTiles summary={data} />
      <SegmentBars shares={data.segmentShares} />
      <section className={styles.priority}>
        <div className={styles.heading}>
          <h2>Priority list</h2>
          <TierFilter options={[null, 'High', 'Medium']} selected={tier} onSelect={setTier} />
        </div>
        <CustomerTable customers={rows} />
      </section>
    </>
  )
}
