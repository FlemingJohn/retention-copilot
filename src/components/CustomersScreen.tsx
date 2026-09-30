'use client'

import { useState } from 'react'
import CustomerTable from '@/components/CustomerTable'
import ErrorMessage from '@/components/ErrorMessage'
import LoadingState from '@/components/LoadingState'
import PageHeader from '@/components/PageHeader'
import TierFilter from '@/components/TierFilter'
import { useCustomers } from '@/hooks/useCustomers'
import { useDebouncedValue } from '@/hooks/useDebouncedValue'
import styles from '@/components/CustomersScreen.module.css'
import type { RiskTier } from '@/types/RiskTier'

export default function CustomersScreen() {
  const [search, setSearch] = useState('')
  const [tier, setTier] = useState<RiskTier | null>(null)
  const debouncedSearch = useDebouncedValue(search.trim(), 300)
  const { data, errorMessage, isLoading, reload } = useCustomers(debouncedSearch, tier)

  return (
    <>
      <PageHeader title="Customers" subtitle="Search by customer id, first name or city" />
      <div className={styles.controls}>
        <input
          className={styles.search}
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="Search customers"
          aria-label="Search customers"
          maxLength={60}
        />
        <TierFilter options={[null, 'High', 'Medium', 'Low']} selected={tier} onSelect={setTier} />
      </div>
      {errorMessage !== null ? <ErrorMessage message={errorMessage} onRetry={reload} /> : null}
      {isLoading && data === null ? <LoadingState label="Loading customers" /> : null}
      {data !== null && errorMessage === null ? <CustomerTable customers={data} /> : null}
    </>
  )
}
