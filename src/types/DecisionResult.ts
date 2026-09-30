import type { ActionStatus } from '@/types/ActionStatus'

export interface DecisionResult {
  message: string
  newStatus: ActionStatus
}
