'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { applyAgentEvent } from '@/lib/chat/applyAgentEvent'
import { createChatEntry } from '@/lib/chat/createChatEntry'
import { streamAnswer } from '@/lib/chat/streamAnswer'
import { readErrorMessage } from '@/lib/api/readErrorMessage'
import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { ChatEntry } from '@/types/ChatEntry'

function updateLastEntry(entries: ChatEntry[], change: (entry: ChatEntry) => ChatEntry): ChatEntry[] {
  const lastIndex = entries.length - 1
  return entries.map((entry, index) => (index === lastIndex ? change(entry) : entry))
}

export function useAskAgent() {
  const [entries, setEntries] = useState<ChatEntry[]>([])
  const [isAnswering, setIsAnswering] = useState(false)
  const latestEntries = useRef<ChatEntry[]>([])

  useEffect(() => {
    latestEntries.current = entries
  }, [entries])

  const ask = useCallback(async (question: string) => {
    const history = [...latestEntries.current, createChatEntry('user', question)]
    setEntries([...history, createChatEntry('assistant', '')])
    setIsAnswering(true)
    const onEvent = (event: AgentStreamEvent) =>
      setEntries((current) => updateLastEntry(current, (entry) => applyAgentEvent(entry, event)))
    try {
      await streamAnswer(history, onEvent)
    } catch (error) {
      setEntries((current) =>
        updateLastEntry(current, (entry) => ({ ...entry, hasFailed: true, text: readErrorMessage(error) })),
      )
    } finally {
      setIsAnswering(false)
    }
  }, [])

  return { entries, isAnswering, ask }
}
