export interface TextBlock {
  kind: 'paragraph' | 'bullets' | 'numbers'
  lines: string[]
}
