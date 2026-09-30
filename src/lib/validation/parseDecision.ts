import { failValidation } from '@/lib/validation/failValidation'

const allowedDecisions = ['Approved', 'Dismissed', 'Needs review']

export function parseDecision(value: unknown): string {
  if (typeof value !== 'string' || !allowedDecisions.includes(value)) {
    failValidation('Decision must be Approved, Dismissed or Needs review')
  }
  return value as string
}
