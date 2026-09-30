'use client'

import { useFetchedData } from '@/hooks/useFetchedData'
import type { CustomerProfile } from '@/types/CustomerProfile'

export function useCustomerProfile(customerId: string) {
  return useFetchedData<CustomerProfile>(`/api/customers/${encodeURIComponent(customerId)}`)
}
