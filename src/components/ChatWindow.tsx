'use client'

import { useEffect, useRef } from 'react'
import ChatBubble from '@/components/ChatBubble'
import styles from '@/components/ChatWindow.module.css'
import type { ChatEntry } from '@/types/ChatEntry'

export default function ChatWindow({ entries, onAsk }: { entries: ChatEntry[]; onAsk: (question: string) => void }) {
  const end = useRef<HTMLDivElement>(null)

  useEffect(() => {
    end.current?.scrollIntoView({ behavior: 'smooth', block: 'end' })
  }, [entries])

  return (
    <div className={styles.window} aria-live="polite">
      {entries.map((entry, index) => (
        <ChatBubble key={index} entry={entry} onAsk={onAsk} />
      ))}
      <div ref={end} />
    </div>
  )
}
