import { failValidation } from '@/lib/validation/failValidation'
import type { RiskTier } from '@/types/RiskTier'

export function parseTier(value: string | null): RiskTier | null {
  if (value === null || value === '') {
    return null
  }
  if (value !== 'High' && value !== 'Medium' && value !== 'Low') {
    failValidation('Tier must be High, Medium or Low')
  }
  return value as RiskTier
}
