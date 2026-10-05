import type { JsonObject } from '@/types/JsonObject'
import type { VegaChannel } from '@/types/VegaChannel'

export function readChartChannel(encoding: JsonObject, name: string): VegaChannel | null {
  const channel = encoding[name] as JsonObject | undefined
  if (channel === undefined || typeof channel.field !== 'string') {
    return null
  }
  return { field: channel.field, type: String(channel.type ?? '') }
}
