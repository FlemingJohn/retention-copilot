interface EventBlock {
  eventName: string
  dataText: string
}

export function parseEventBlock(block: string): EventBlock {
  let eventName = ''
  const dataLines: string[] = []
  for (const line of block.split('\n')) {
    if (line.startsWith('event:')) {
      eventName = line.slice(6).trim()
    } else if (line.startsWith('data:')) {
      dataLines.push(line.slice(5).trim())
    }
  }
  return { eventName, dataText: dataLines.join('\n') }
}
