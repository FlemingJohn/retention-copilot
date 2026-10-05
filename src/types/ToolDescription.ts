import type { ToolKind } from '@/types/ToolKind'

export interface ToolDescription {
  runningLabel: string
  doneLabel: string
  kind: ToolKind
}
