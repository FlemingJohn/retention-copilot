import { failValidation } from '@/lib/validation/failValidation'

export function parseCustomerId(value: unknown): string {
  if (typeof value !== 'string' || !/^C\d{6}$/.test(value)) {
    failValidation('Customer id must look like C000123')
  }
  return value as string
}
