import type { TextBlock } from '@/types/TextBlock'

const bulletPattern = /^\s*[-*•]\s+(.*)$/
const numberPattern = /^\s*\d+[.)]\s+(.*)$/
const headingPattern = /^\s*#{1,4}\s+(.*)$/

function classifyLine(line: string): { kind: TextBlock['kind'] | 'blank'; content: string } {
  if (line.trim() === '') {
    return { kind: 'blank', content: '' }
  }
  const heading = headingPattern.exec(line)
  if (heading) {
    return { kind: 'paragraph', content: `**${heading[1]}**` }
  }
  const bullet = bulletPattern.exec(line)
  if (bullet) {
    return { kind: 'bullets', content: bullet[1] }
  }
  const number = numberPattern.exec(line)
  return number ? { kind: 'numbers', content: number[1] } : { kind: 'paragraph', content: line.trim() }
}

export function parseTextBlocks(text: string): TextBlock[] {
  const blocks: TextBlock[] = []
  let open: TextBlock | null = null
  for (const line of text.split('\n')) {
    const { kind, content } = classifyLine(line)
    if (kind === 'blank') {
      open = null
      continue
    }
    if (open === null || open.kind !== kind) {
      open = { kind, lines: [] }
      blocks.push(open)
    }
    open.lines.push(content)
  }
  return blocks
}
