import { errorResponse } from '@/lib/http/errorResponse'
import { jsonResponse } from '@/lib/http/jsonResponse'
import { getCustomerProfile } from '@/lib/queries/getCustomerProfile'
import { parseCustomerId } from '@/lib/validation/parseCustomerId'

export const dynamic = 'force-dynamic'

export async function GET(_request: Request, context: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const customerId = parseCustomerId((await context.params).id)
    const profile = await getCustomerProfile(customerId)
    return profile === null ? jsonResponse({ message: 'Customer not found' }, 404) : jsonResponse(profile)
  } catch (error) {
    return errorResponse(error)
  }
}
