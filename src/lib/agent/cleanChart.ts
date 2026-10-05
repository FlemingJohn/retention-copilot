import { readChartChannel } from '@/lib/agent/readChartChannel'
import { readChartUnit } from '@/lib/chat/readChartUnit'
import type { AgentChart } from '@/types/AgentChart'
import type { JsonObject } from '@/types/JsonObject'
import type { VegaChannel } from '@/types/VegaChannel'

const mostPoints = 12
const fewestPoints = 2

function parseSpec(specText: string): JsonObject | null {
  try {
    return JSON.parse(specText) as JsonObject
  } catch {
    return null
  }
}

function pickFields(encoding: JsonObject): { labelField: string; valueField: string } | null {
  const channels = ['y', 'x', 'theta', 'color']
    .map((name) => readChartChannel(encoding, name))
    .filter((channel): channel is VegaChannel => channel !== null)
  const value = channels.find((channel) => channel.type === 'quantitative')
  const label = channels.find((channel) => channel.type !== 'quantitative')
  return value && label ? { labelField: label.field, valueField: value.field } : null
}

function readTitle(spec: JsonObject): string {
  const title = spec.title
  if (typeof title === 'string') {
    return title
  }
  return typeof (title as JsonObject | undefined)?.text === 'string' ? String((title as JsonObject).text) : ''
}

function readRows(spec: JsonObject): JsonObject[] {
  const values = (spec.data as JsonObject | undefined)?.values
  return Array.isArray(values) ? (values as JsonObject[]) : []
}

export function cleanChart(specText: string): AgentChart | null {
  const spec = parseSpec(specText)
  const fields = spec === null ? null : pickFields((spec.encoding ?? {}) as JsonObject)
  if (spec === null || fields === null) {
    return null
  }
  const points = readRows(spec)
    .map((row) => ({ label: String(row[fields.labelField]), value: Number(row[fields.valueField]) }))
    .filter((point) => Number.isFinite(point.value))
    .slice(0, mostPoints)
  if (points.length < fewestPoints) {
    return null
  }
  return {
    title: readTitle(spec),
    labels: points.map((point) => point.label),
    values: points.map((point) => point.value),
    unit: readChartUnit(fields.valueField),
  }
}
