import type { AgentStreamEvent } from '@/types/AgentStreamEvent'
import type { ChatEntry } from '@/types/ChatEntry'

const failureText = 'The assistant could not finish that request. Please try again.'
const mostSources = 4

function moveTextToThinking(entry: ChatEntry): ChatEntry {
  if (entry.text.trim() === '') {
    return entry
  }
  return { ...entry, thinking: `${entry.thinking}\n${entry.text.trim()}\n`, text: '' }
}

function addStep(entry: ChatEntry, id: string, name: string, detail: string): ChatEntry {
  if (entry.steps.some((step) => step.id === id)) {
    return entry
  }
  const quiet = moveTextToThinking(entry)
  return { ...quiet, steps: [...quiet.steps, { id, name, detail, isDone: false }] }
}

function finishStep(entry: ChatEntry, id: string): ChatEntry {
  const steps = entry.steps.map((step) => (step.id === id ? { ...step, isDone: true } : step))
  return { ...entry, steps }
}

function addSource(entry: ChatEntry, text: string): ChatEntry {
  if (entry.sources.includes(text) || entry.sources.length >= mostSources) {
    return entry
  }
  return { ...entry, sources: [...entry.sources, text] }
}

function finishEntry(entry: ChatEntry): ChatEntry {
  const steps = entry.steps.map((step) => ({ ...step, isDone: true }))
  return { ...entry, steps, status: '', isFinished: true }
}

function failEntry(entry: ChatEntry): ChatEntry {
  const text = entry.text === '' ? failureText : entry.text
  return { ...finishEntry(entry), hasFailed: true, text }
}

export function applyAgentEvent(entry: ChatEntry, event: AgentStreamEvent): ChatEntry {
  switch (event.type) {
    case 'text':
      return { ...entry, text: entry.text + event.text }
    case 'thinking':
      return { ...entry, thinking: entry.thinking + event.text }
    case 'status':
      return { ...entry, status: event.message }
    case 'tool':
      return addStep(entry, event.id, event.name, event.detail)
    case 'toolDone':
      return finishStep(entry, event.id)
    case 'table':
      return { ...entry, table: event.table }
    case 'chart':
      return { ...entry, chart: event.chart }
    case 'source':
      return addSource(entry, event.text)
    case 'suggestions':
      return { ...entry, suggestions: event.questions }
    case 'error':
      return failEntry(entry)
    case 'finished':
      return finishEntry(entry)
    default:
      return entry
  }
}
