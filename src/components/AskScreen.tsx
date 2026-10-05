'use client'

import { useSearchParams } from 'next/navigation'
import { useEffect, useRef } from 'react'
import AskIntro from '@/components/AskIntro'
import ChatWindow from '@/components/ChatWindow'
import PageHeader from '@/components/PageHeader'
import QuestionForm from '@/components/QuestionForm'
import { useAskAgent } from '@/hooks/useAskAgent'
import styles from '@/components/AskScreen.module.css'

export default function AskScreen() {
  const { entries, isAnswering, ask } = useAskAgent()
  const initialQuestion = useSearchParams().get('question')
  const hasAskedInitial = useRef(false)

  useEffect(() => {
    if (initialQuestion !== null && initialQuestion.trim() !== '' && !hasAskedInitial.current) {
      hasAskedInitial.current = true
      void ask(initialQuestion.trim().slice(0, 500))
    }
  }, [initialQuestion, ask])

  const askQuestion = (question: string) => void ask(question)

  return (
    <div className={styles.screen}>
      <PageHeader title="Ask" subtitle="Ask in plain English. Answers come from your governed customer data." />
      <div className={styles.conversation}>
        {entries.length === 0 ? <AskIntro onPick={askQuestion} /> : <ChatWindow entries={entries} onAsk={askQuestion} />}
      </div>
      <div className={styles.composer}>
        <QuestionForm disabled={isAnswering} onSubmit={askQuestion} />
      </div>
    </div>
  )
}
