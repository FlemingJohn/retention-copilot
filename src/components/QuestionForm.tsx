'use client'

import { useState } from 'react'
import type { FormEvent } from 'react'
import Button from '@/components/Button'
import SendIcon from '@/components/SendIcon'
import styles from '@/components/QuestionForm.module.css'

export default function QuestionForm({
  disabled,
  onSubmit,
}: {
  disabled: boolean
  onSubmit: (question: string) => void
}) {
  const [text, setText] = useState('')

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const trimmed = text.trim()
    if (trimmed === '' || disabled) {
      return
    }
    setText('')
    onSubmit(trimmed)
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit}>
      <input
        className={styles.input}
        value={text}
        onChange={(event) => setText(event.target.value)}
        placeholder="Ask about customers, risk or actions"
        aria-label="Your question"
        maxLength={500}
      />
      <Button type="submit" disabled={disabled}>
        <SendIcon size={16} />
        Ask
      </Button>
    </form>
  )
}
