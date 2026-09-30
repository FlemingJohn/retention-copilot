export type SentimentLabel = 'Negative' | 'Neutral' | 'Positive'

export function describeSentiment(score: number | null): SentimentLabel | null {
  if (score === null) {
    return null
  }
  if (score < -0.25) {
    return 'Negative'
  }
  if (score > 0.25) {
    return 'Positive'
  }
  return 'Neutral'
}
