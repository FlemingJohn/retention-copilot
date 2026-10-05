import SparkIcon from '@/components/SparkIcon'
import SuggestedQuestions from '@/components/SuggestedQuestions'
import { starterQuestions } from '@/lib/chat/starterQuestions'
import styles from '@/components/AskIntro.module.css'

export default function AskIntro({ onPick }: { onPick: (question: string) => void }) {
  return (
    <section className={styles.intro}>
      <span className={styles.mark}>
        <SparkIcon size={28} />
      </span>
      <h2>What would you like to know?</h2>
      <p className={styles.note}>
        The copilot reads your governed customer data, searches call transcripts and shows each step it takes.
      </p>
      <SuggestedQuestions heading="Try one of these" questions={starterQuestions} onPick={onPick} />
    </section>
  )
}
