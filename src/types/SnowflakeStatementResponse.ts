import type { SnowflakeColumn } from '@/types/SnowflakeColumn'

export interface SnowflakeStatementResponse {
  statementHandle: string
  data: Array<Array<string | null>>
  resultSetMetaData: {
    rowType: SnowflakeColumn[]
    partitionInfo: unknown[]
  }
}
