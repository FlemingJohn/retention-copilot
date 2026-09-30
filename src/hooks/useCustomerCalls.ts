'use client'

import { useFetchedData } from '@/hooks/useFetchedData'
import type { CallSummary } from '@/types/CallSummary'

export function useCustomerCalls(customerId: string) {
  return useFetchedData<CallSummary[]>(`/api/customers/${encodeURIComponent(customerId)}/calls`)
}
