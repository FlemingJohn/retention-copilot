export interface CallSummary {
  transcriptId: string
  customerId: string
  callAt: string
  sentimentScore: number | null
  mainTopic: string | null
  competitorMentioned: string | null
  complaintReason: string | null
  wantsToCancel: boolean | null
  transcriptText: string
}
