import { readNullableBoolean, readNullableNumber, readNullableText, readText } from '@/lib/queries/rowReaders'
import type { CallSummary } from '@/types/CallSummary'
import type { SnowflakeRow } from '@/types/SnowflakeRow'

export function mapCall(row: SnowflakeRow): CallSummary {
  return {
    transcriptId: readText(row, 'TRANSCRIPT_ID'),
    customerId: readText(row, 'CUSTOMER_ID'),
    callAt: readText(row, 'CALL_AT'),
    sentimentScore: readNullableNumber(row, 'SENTIMENT_SCORE'),
    mainTopic: readNullableText(row, 'MAIN_TOPIC'),
    competitorMentioned: readNullableText(row, 'COMPETITOR_MENTIONED'),
    complaintReason: readNullableText(row, 'COMPLAINT_REASON'),
    wantsToCancel: readNullableBoolean(row, 'WANTS_TO_CANCEL'),
    transcriptText: readText(row, 'TRANSCRIPT_TEXT'),
  }
}
