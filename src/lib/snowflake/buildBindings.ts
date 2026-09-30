import 'server-only'

interface Binding {
  type: 'TEXT' | 'FIXED'
  value: string
}

export function buildBindings(values: Array<string | number>): Record<string, Binding> {
  const bindings: Record<string, Binding> = {}
  values.forEach((value, index) => {
    bindings[String(index + 1)] = {
      type: typeof value === 'number' ? 'FIXED' : 'TEXT',
      value: String(value),
    }
  })
  return bindings
}
