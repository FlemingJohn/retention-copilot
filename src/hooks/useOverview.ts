'use client'

import { useFetchedData } from '@/hooks/useFetchedData'
import type { OverviewSummary } from '@/types/OverviewSummary'

export function useOverview() {
  return useFetchedData<OverviewSummary>('/api/overview')
}
