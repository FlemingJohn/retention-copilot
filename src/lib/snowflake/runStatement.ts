import 'server-only'
import { readConfiguration } from '@/lib/config/readConfiguration'
import { ServiceError } from '@/lib/errors/ServiceError'
import { buildBindings } from '@/lib/snowflake/buildBindings'
import { buildRequestHeaders } from '@/lib/snowflake/buildRequestHeaders'
import { mapRows } from '@/lib/snowflake/mapRows'
import type { SnowflakeRow } from '@/types/SnowflakeRow'
import type { SnowflakeStatementResponse } from '@/types/SnowflakeStatementResponse'

const failureMessage = 'The data service could not complete the request'

async function readBody(response: Response): Promise<SnowflakeStatementResponse> {
  if (!response.ok) {
    console.error('Data service request failed with status', response.status)
    throw new ServiceError(failureMessage, 502)
  }
  return (await response.json()) as SnowflakeStatementResponse
}

async function fetchPartition(handle: string, partition: number): Promise<Array<Array<string | null>>> {
  const configuration = readConfiguration()
  const url = `${configuration.accountUrl}/api/v2/statements/${handle}?partition=${partition}`
  const response = await fetch(url, { headers: buildRequestHeaders(configuration.token), cache: 'no-store' })
  return (await readBody(response)).data
}

export async function runStatement(statement: string, values: Array<string | number> = []): Promise<SnowflakeRow[]> {
  const configuration = readConfiguration()
  const response = await fetch(`${configuration.accountUrl}/api/v2/statements`, {
    method: 'POST',
    headers: buildRequestHeaders(configuration.token),
    cache: 'no-store',
    body: JSON.stringify({
      statement,
      timeout: 60,
      warehouse: configuration.warehouse,
      role: configuration.role,
      database: configuration.database,
      schema: configuration.schema,
      bindings: buildBindings(values),
    }),
  })
  const body = await readBody(response)
  const rows = [...body.data]
  const partitionCount = body.resultSetMetaData.partitionInfo.length
  for (let partition = 1; partition < partitionCount; partition += 1) {
    rows.push(...(await fetchPartition(body.statementHandle, partition)))
  }
  return mapRows(body.resultSetMetaData.rowType, rows)
}
