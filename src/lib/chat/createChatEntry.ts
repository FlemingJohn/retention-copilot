import type { ChatEntry } from '@/types/ChatEntry'

export function createChatEntry(role: 'user' | 'assistant', text: string): ChatEntry {
  return {
    role,
    text,
    thinking: '',
    status: role === 'assistant' ? 'Starting' : '',
    steps: [],
    table: null,
    chart: null,
    sources: [],
    suggestions: [],
    hasFailed: false,
    isFinished: role === 'user',
  }
}
