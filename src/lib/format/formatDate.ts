export function formatDate(isoText: string): string {
  const date = new Date(isoText)
  if (Number.isNaN(date.getTime())) {
    return isoText
  }
  return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' })
}
