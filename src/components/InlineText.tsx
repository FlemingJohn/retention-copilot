import { splitInline } from '@/lib/chat/splitInline'

export default function InlineText({ text }: { text: string }) {
  return (
    <>
      {splitInline(text).map((piece, index) => {
        if (piece.isBold) {
          return <strong key={index}>{piece.text}</strong>
        }
        return piece.isItalic ? <em key={index}>{piece.text}</em> : <span key={index}>{piece.text}</span>
      })}
    </>
  )
}
