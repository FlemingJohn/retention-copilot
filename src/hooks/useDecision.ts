'use client'

import { useCallback, useState } from 'react'
import { readErrorMessage } from '@/lib/api/readErrorMessage'
import { readJsonOrThrow } from '@/lib/api/readJsonOrThrow'
import type { DecisionResult } from '@/types/DecisionResult'

export function useDecision(actionId: string) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)

  const submit = useCallback(
    async (decision: string, note: string): Promise<DecisionResult | null> => {
      setIsSubmitting(true)
      setErrorMessage(null)
      try {
        const response = await fetch(`/api/recommendations/${encodeURIComponent(actionId)}/decision`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ decision, note }),
        })
        return (await readJsonOrThrow(response)) as DecisionResult
      } catch (error) {
        setErrorMessage(readErrorMessage(error))
        return null
      } finally {
        setIsSubmitting(false)
      }
    },
    [actionId],
  )

  return { submit, isSubmitting, errorMessage }
}
