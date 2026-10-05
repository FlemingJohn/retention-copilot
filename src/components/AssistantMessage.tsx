import BarChart from '@/components/BarChart'
import CustomerCards from '@/components/CustomerCards'
import FormattedText from '@/components/FormattedText'
import ResultTable from '@/components/ResultTable'
import SourceList from '@/components/SourceList'
import SparkIcon from '@/components/SparkIcon'
import StepList from '@/components/StepList'
import SuggestedQuestions from '@/components/SuggestedQuestions'
import { chartFromTable } from '@/lib/chat/chartFromTable'
import { findCustomerMentions } from '@/lib/chat/findCustomerMentions'
import styles from '@/components/AssistantMessage.module.css'
import type { ChatEntry } from '@/types/ChatEntry'

export default function AssistantMessage({ entry, onAsk }: { entry: ChatEntry; onAsk: (question: string) => void }) {
  const mentions = findCustomerMentions(entry.table)
  const chart = entry.chart ?? chartFromTable(entry.table)
  return (
    <article className={`${styles.message} ${entry.hasFailed ? styles.failed : ''}`}>
      <header className={styles.author}>
        <SparkIcon size={18} />
        Copilot
      </header>
      <StepList entry={entry} />
      {entry.text !== '' ? <FormattedText text={entry.text} /> : null}
      {chart !== null ? <BarChart chart={chart} /> : null}
      {mentions.length > 0 ? <CustomerCards mentions={mentions} /> : null}
      {entry.table !== null ? (
        <details className={styles.table} open={mentions.length === 0}>
          <summary>Show the table ({entry.table.rows.length} rows)</summary>
          <ResultTable table={entry.table} />
        </details>
      ) : null}
      {entry.sources.length > 0 ? <SourceList sources={entry.sources} /> : null}
      {entry.isFinished && entry.suggestions.length > 0 ? (
        <SuggestedQuestions heading="Follow-ups" questions={entry.suggestions} onPick={onAsk} />
      ) : null}
    </article>
  )
}
