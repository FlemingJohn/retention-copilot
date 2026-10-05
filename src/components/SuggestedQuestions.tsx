import styles from '@/components/SuggestedQuestions.module.css'

export default function SuggestedQuestions({
  questions,
  onPick,
  heading,
}: {
  questions: string[]
  onPick: (question: string) => void
  heading?: string
}) {
  return (
    <div className={styles.group}>
      {heading ? <span className={styles.heading}>{heading}</span> : null}
      <div className={styles.list}>
        {questions.map((question) => (
          <button key={question} type="button" className={styles.item} onClick={() => onPick(question)}>
            {question}
          </button>
        ))}
      </div>
    </div>
  )
}
