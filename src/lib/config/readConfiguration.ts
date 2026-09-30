import 'server-only'
import type { SnowflakeConfiguration } from '@/types/SnowflakeConfiguration'

function readRequired(name: string): string {
  const value = process.env[name]
  if (!value) {
    throw new Error(`Missing environment variable ${name}`)
  }
  return value
}

export function readConfiguration(): SnowflakeConfiguration {
  return {
    accountUrl: readRequired('SNOWFLAKE_ACCOUNT_URL').replace(/\/$/, ''),
    token: readRequired('SNOWFLAKE_TOKEN'),
    warehouse: readRequired('SNOWFLAKE_WAREHOUSE'),
    database: readRequired('SNOWFLAKE_DATABASE'),
    schema: readRequired('SNOWFLAKE_SCHEMA'),
    role: readRequired('SNOWFLAKE_ROLE'),
    agentName: readRequired('SNOWFLAKE_AGENT'),
  }
}
