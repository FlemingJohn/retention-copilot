import { errorResponse } from '@/lib/http/errorResponse'
import { jsonResponse } from '@/lib/http/jsonResponse'
import { getOverview } from '@/lib/queries/getOverview'

export const dynamic = 'force-dynamic'

export async function GET(): Promise<Response> {
  try {
    return jsonResponse(await getOverview())
  } catch (error) {
    return errorResponse(error)
  }
}
