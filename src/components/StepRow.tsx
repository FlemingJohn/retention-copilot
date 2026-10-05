import CheckIcon from '@/components/CheckIcon'
import SpinnerIcon from '@/components/SpinnerIcon'
import ToolIcon from '@/components/ToolIcon'
import { describeTool } from '@/lib/chat/describeTool'
import styles from '@/components/StepRow.module.css'
import type { ChatStep } from '@/types/ChatStep'

export default function StepRow({ step }: { step: ChatStep }) {
  const tool = describeTool(step.name)
  return (
    <li className={styles.row}>
      <span className={styles.icon}>
        <ToolIcon kind={tool.kind} size={18} />
      </span>
      <span className={styles.body}>
        <span className={styles.label}>{step.isDone ? tool.doneLabel : tool.runningLabel}</span>
        {step.detail !== '' ? (
          <code className={styles.detail} title={step.detail}>
            {step.detail}
          </code>
        ) : null}
      </span>
      <span className={step.isDone ? styles.done : styles.running}>
        {step.isDone ? <CheckIcon size={16} /> : <SpinnerIcon size={16} />}
      </span>
    </li>
  )
}
