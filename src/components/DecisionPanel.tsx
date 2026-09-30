'use client'

import { useState } from 'react'
import Button from '@/components/Button'
import { useDecision } from '@/hooks/useDecision'
import styles from '@/components/DecisionPanel.module.css'
import type { ActionStatus } from '@/types/ActionStatus'

type Choice = 'Approved' | 'Dismissed'

export default function DecisionPanel({
  actionId,
  onDecided,
}: {
  actionId: string
  onDecided: (newStatus: ActionStatus) => void
}) {
  const [choice, setChoice] = useState<Choice | null>(null)
  const [note, setNote] = useState('')
  const [confirmation, setConfirmation] = useState<string | null>(null)
  const { submit, isSubmitting, errorMessage } = useDecision(actionId)

  async function confirm() {
    if (choice === null) {
      return
    }
    const result = await submit(choice, note)
    if (result !== null) {
      setConfirmation(result.message)
      setChoice(null)
      setNote('')
      onDecided(result.newStatus)
    }
  }

  return (
    <div className={styles.panel}>
      <div className={styles.buttons}>
        <Button onClick={() => setChoice('Approved')}>Approve</Button>
        <Button variant="secondary" onClick={() => setChoice('Dismissed')}>
          Dismiss
        </Button>
      </div>
      {choice !== null ? (
        <div className={styles.confirm}>
          <label className={styles.label} htmlFor={`note-${actionId}`}>
            {choice === 'Approved' ? 'Approve this action?' : 'Dismiss this action?'} Add a note if you like.
          </label>
          <textarea
            id={`note-${actionId}`}
            className={styles.note}
            value={note}
            onChange={(event) => setNote(event.target.value)}
            maxLength={300}
            rows={2}
          />
          <div className={styles.buttons}>
            <Button onClick={confirm} disabled={isSubmitting}>
              {isSubmitting ? 'Saving' : 'Confirm'}
            </Button>
            <Button variant="secondary" onClick={() => setChoice(null)} disabled={isSubmitting}>
              Cancel
            </Button>
          </div>
        </div>
      ) : null}
      {errorMessage !== null ? <p className={styles.error}>{errorMessage}</p> : null}
      {confirmation !== null ? <p className={styles.done}>{confirmation}</p> : null}
    </div>
  )
}
