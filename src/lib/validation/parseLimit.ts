import { failValidation } from '@/lib/validation/failValidation'

const defaultLimit = 50
const largestLimit = 100

export function parseLimit(value: string | null): number {
  if (value === null || value === '') {
    return defaultLimit
  }
  const limit = Number(value)
  if (!Number.isInteger(limit) || limit < 1 || limit > largestLimit) {
    failValidation(`Limit must be a whole number from 1 to ${largestLimit}`)
  }
  return limit
}
