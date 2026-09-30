'use client'

import { useEffect, useRef } from 'react'
import ChatBubble from '@/components/ChatBubble'
import styles from '@/components/ChatWindow.module.css'
import type { ChatEntry } from '@/types/ChatEntry'

export default function ChatWindow({ entries, isAnswering }: { entries: ChatEntry[]; isAnswering: boolean }) {
  const end = useRef<HTMLDivElement>(null)

  useEffect(() => {
    end.current?.scrollIntoView({ behavior: 'smooth', block: 'end' })
  }, [entries])

  return (
    <div className={styles.window} aria-live="polite">
      {entries.map((entry, index) => (
        <ChatBubble key={index} entry={entry} isWaiting={isAnswering && index === entries.length - 1} />
      ))}
      <div ref={end} />
    </div>
  )
}
