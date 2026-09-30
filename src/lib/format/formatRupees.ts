const oneLakh = 100_000
const oneCrore = 10_000_000

export function formatRupees(amount: number | null): string {
  if (amount === null) {
    return '-'
  }
  if (amount >= oneCrore) {
    return `₹${(amount / oneCrore).toFixed(2)} crore`
  }
  if (amount >= oneLakh) {
    return `₹${(amount / oneLakh).toFixed(1)} lakh`
  }
  return `₹${Math.round(amount).toLocaleString('en-IN')}`
}
