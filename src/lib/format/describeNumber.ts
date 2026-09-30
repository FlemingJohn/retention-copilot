export function describeCount(count: number, singular: string, plural = `${singular}s`): string {
  return `${count} ${count === 1 ? singular : plural}`
}

export function describeOptionalNumber(value: number | null, digits = 1): string {
  return value === null ? 'No data' : value.toFixed(digits)
}
