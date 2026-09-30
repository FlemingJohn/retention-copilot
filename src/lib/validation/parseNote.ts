import { failValidation } from '@/lib/validation/failValidation'

const longestNote = 300

export function parseNote(value: unknown): string {
  if (value === undefined || value === null) {
    return ''
  }
  if (typeof value !== 'string') {
    failValidation('Note must be text')
  }
  const cleaned = (value as string).replace(/[\u0000-\u001f]/g, ' ').trim()
  if (cleaned.length > longestNote) {
    failValidation(`Note must be at most ${longestNote} characters`)
  }
  return cleaned
}
