import 'server-only'

export function buildRequestHeaders(token: string, accept = 'application/json'): Record<string, string> {
  return {
    Authorization: `Bearer ${token}`,
    'X-Snowflake-Authorization-Token-Type': 'PROGRAMMATIC_ACCESS_TOKEN',
    'Content-Type': 'application/json',
    Accept: accept,
  }
}
