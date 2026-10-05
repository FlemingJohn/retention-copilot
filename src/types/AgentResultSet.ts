export interface AgentResultSet {
  data?: string[][]
  resultSetMetaData?: { rowType?: Array<{ name: string }> }
}
