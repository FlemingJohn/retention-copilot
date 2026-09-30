import 'server-only'
import { cleanAgentEvent } from '@/lib/agent/cleanAgentEvent'
import { parseEventBlock } from '@/lib/agent/parseEventBlock'
import type { AgentStreamEvent } from '@/types/AgentStreamEvent'

const encoder = new TextEncoder()

function enqueueEvent(controller: TransformStreamDefaultController<Uint8Array>, event: AgentStreamEvent): void {
  controller.enqueue(encoder.encode(`${JSON.stringify(event)}\n`))
}

function handleBlock(controller: TransformStreamDefaultController<Uint8Array>, block: string): void {
  const { eventName, dataText } = parseEventBlock(block.replace(/\r/g, ''))
  const event = cleanAgentEvent(eventName, dataText)
  if (event !== null) {
    enqueueEvent(controller, event)
  }
}

export function streamAgentEvents(upstream: ReadableStream<Uint8Array>): ReadableStream<Uint8Array> {
  const decoder = new TextDecoder()
  let buffer = ''
  const transformer = new TransformStream<Uint8Array, Uint8Array>({
    transform(chunk, controller) {
      buffer += decoder.decode(chunk, { stream: true })
      const blocks = buffer.replace(/\r\n/g, '\n').split('\n\n')
      buffer = blocks.pop() ?? ''
      blocks.forEach((block) => handleBlock(controller, block))
    },
    flush(controller) {
      if (buffer.trim() !== '') {
        handleBlock(controller, buffer)
      }
      enqueueEvent(controller, { type: 'finished' })
    },
  })
  return upstream.pipeThrough(transformer)
}
