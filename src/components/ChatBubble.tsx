import AssistantMessage from '@/components/AssistantMessage'
import UserMessage from '@/components/UserMessage'
import type { ChatEntry } from '@/types/ChatEntry'

export default function ChatBubble({ entry, onAsk }: { entry: ChatEntry; onAsk: (question: string) => void }) {
  return entry.role === 'user' ? <UserMessage text={entry.text} /> : <AssistantMessage entry={entry} onAsk={onAsk} />
}
