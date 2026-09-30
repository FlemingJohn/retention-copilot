import { errorResponse } from '@/lib/http/errorResponse'
import { jsonResponse } from '@/lib/http/jsonResponse'
import { listCustomerCalls } from '@/lib/queries/listCustomerCalls'
import { parseCustomerId } from '@/lib/validation/parseCustomerId'

export const dynamic = 'force-dynamic'

export async function GET(_request: Request, context: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const customerId = parseCustomerId((await context.params).id)
    return jsonResponse(await listCustomerCalls(customerId))
  } catch (error) {
    return errorResponse(error)
  }
}
