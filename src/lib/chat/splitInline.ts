import type { TextPiece } from '@/types/TextPiece'

const markedPattern = /(\*\*[^*]+\*\*|\*[^*\s][^*]*\*)/

function toPiece(piece: string): TextPiece {
  if (piece.startsWith('**') && piece.endsWith('**') && piece.length > 4) {
    return { text: piece.slice(2, -2), isBold: true, isItalic: false }
  }
  if (piece.startsWith('*') && piece.endsWith('*') && piece.length > 2) {
    return { text: piece.slice(1, -1), isBold: false, isItalic: true }
  }
  return { text: piece, isBold: false, isItalic: false }
}

export function splitInline(text: string): TextPiece[] {
  return text
    .split(markedPattern)
    .filter((piece) => piece !== '')
    .map(toPiece)
}
