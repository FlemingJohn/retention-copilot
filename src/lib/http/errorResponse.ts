import { ServiceError } from '@/lib/errors/ServiceError'
import { jsonResponse } from '@/lib/http/jsonResponse'

export function errorResponse(error: unknown): Response {
  if (error instanceof ServiceError) {
    return jsonResponse({ message: error.message }, error.statusCode)
  }
  console.error('Unexpected server error')
  return jsonResponse({ message: 'Something went wrong' }, 500)
}
