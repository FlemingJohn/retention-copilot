'use client'

import { useRouter } from 'next/navigation'
import { useState } from 'react'
import type { FormEvent } from 'react'
import SearchIcon from '@/components/SearchIcon'
import styles from '@/components/AskOrSearchBox.module.css'

const customerIdPattern = /^C\d{6}$/i

export default function AskOrSearchBox() {
  const router = useRouter()
  const [text, setText] = useState('')

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const trimmed = text.trim()
    if (trimmed === '') {
      return
    }
    setText('')
    if (customerIdPattern.test(trimmed)) {
      router.push(`/customers/${trimmed.toUpperCase()}`)
      return
    }
    router.push(`/ask?question=${encodeURIComponent(trimmed.slice(0, 500))}`)
  }

  return (
    <form className={styles.box} onSubmit={handleSubmit} role="search">
      <SearchIcon size={18} />
      <input
        className={styles.input}
        value={text}
        onChange={(event) => setText(event.target.value)}
        placeholder="Ask a question or enter a customer id"
        aria-label="Ask a question or enter a customer id"
        maxLength={500}
      />
    </form>
  )
}
