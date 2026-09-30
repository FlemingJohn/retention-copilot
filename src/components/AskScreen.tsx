'use client'

import { useSearchParams } from 'next/navigation'
import { useEffect, useRef } from 'react'
import ChatWindow from '@/components/ChatWindow'
import PageHeader from '@/components/PageHeader'
import QuestionForm from '@/components/QuestionForm'
import SuggestedQuestions from '@/components/SuggestedQuestions'
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

  return (
    <>
      <PageHeader title="Ask" subtitle="Ask in plain English. Answers come from your governed customer data." />
      {entries.length === 0 ? <SuggestedQuestions onPick={(question) => void ask(question)} /> : null}
      <ChatWindow entries={entries} isAnswering={isAnswering} />
      <div className={styles.form}>
        <QuestionForm disabled={isAnswering} onSubmit={(question) => void ask(question)} />
      </div>
    </>
  )
}
