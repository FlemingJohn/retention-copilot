import styles from '@/components/SuggestedQuestions.module.css'

const questions = [
  'Which high risk customers should we call first this week?',
  'What are the top reasons customers are leaving?',
  'How many customers mentioned a competitor, by state?',
  'Which action types are pending approval?',
]

export default function SuggestedQuestions({ onPick }: { onPick: (question: string) => void }) {
  return (
    <div className={styles.list}>
      {questions.map((question) => (
        <button key={question} type="button" className={styles.item} onClick={() => onPick(question)}>
          {question}
        </button>
      ))}
    </div>
  )
}
