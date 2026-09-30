export async function readJsonOrThrow(response: Response): Promise<unknown> {
  const body = (await response.json().catch(() => ({}))) as { message?: string }
  if (!response.ok) {
    throw new Error(body.message ?? 'The request failed')
  }
  return body
}
