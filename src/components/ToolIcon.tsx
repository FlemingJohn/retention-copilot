import ChartIcon from '@/components/ChartIcon'
import DatabaseIcon from '@/components/DatabaseIcon'
import DecisionIcon from '@/components/DecisionIcon'
import SparkIcon from '@/components/SparkIcon'
import TranscriptIcon from '@/components/TranscriptIcon'
import type { ToolKind } from '@/types/ToolKind'

export default function ToolIcon({ kind, size }: { kind: ToolKind; size?: number }) {
  switch (kind) {
    case 'analyst':
    case 'sql':
      return <DatabaseIcon size={size} />
    case 'search':
      return <TranscriptIcon size={size} />
    case 'chart':
      return <ChartIcon size={size} />
    case 'decision':
      return <DecisionIcon size={size} />
    default:
      return <SparkIcon size={size} />
  }
}
