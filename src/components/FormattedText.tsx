import InlineText from '@/components/InlineText'
import { parseTextBlocks } from '@/lib/chat/parseTextBlocks'
import styles from '@/components/FormattedText.module.css'
import type { TextBlock } from '@/types/TextBlock'

function drawBlock(block: TextBlock, index: number) {
  const items = block.lines.map((line, lineIndex) => (
    <li key={lineIndex}>
      <InlineText text={line} />
    </li>
  ))
  if (block.kind === 'bullets') {
    return <ul key={index}>{items}</ul>
  }
  if (block.kind === 'numbers') {
    return <ol key={index}>{items}</ol>
  }
  return (
    <p key={index}>
      <InlineText text={block.lines.join(' ')} />
    </p>
  )
}

export default function FormattedText({ text }: { text: string }) {
  return <div className={styles.text}>{parseTextBlocks(text).map(drawBlock)}</div>
}
