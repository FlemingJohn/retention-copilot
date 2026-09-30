import { failValidation } from '@/lib/validation/failValidation'

export function parseActionId(value: unknown): string {
  if (typeof value !== 'string' || !/^ACT\d{6}$/.test(value)) {
    failValidation('Action id must look like ACT000123')
  }
  return value as string
}
