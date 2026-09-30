import { failValidation } from '@/lib/validation/failValidation'

const longestSearch = 60

export function parseSearchText(value: string | null): string {
  const text = (value ?? '').trim()
  if (text.length > longestSearch) {
    failValidation(`Search must be at most ${longestSearch} characters`)
  }
  if (!/^[A-Za-z0-9 -]*$/.test(text)) {
    failValidation('Search may only use letters, numbers, spaces and hyphens')
  }
  return text
}
