export function formatPercent(fraction: number | null): string {
  if (fraction === null) {
    return '-'
  }
  return `${Math.round(fraction * 100)}%`
}
