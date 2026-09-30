'use client'

import { useFetchedData } from '@/hooks/useFetchedData'
import type { CustomerSummary } from '@/types/CustomerSummary'
import type { RiskTier } from '@/types/RiskTier'

export function useCustomers(search: string, tier: RiskTier | null) {
  const parameters = new URLSearchParams()
  if (search !== '') {
    parameters.set('search', search)
  }
  if (tier !== null) {
    parameters.set('tier', tier)
  }
  parameters.set('limit', '50')
  return useFetchedData<CustomerSummary[]>(`/api/customers?${parameters.toString()}`)
}
