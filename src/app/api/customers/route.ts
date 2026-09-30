import { errorResponse } from '@/lib/http/errorResponse'
import { jsonResponse } from '@/lib/http/jsonResponse'
import { listCustomers } from '@/lib/queries/listCustomers'
import { parseLimit } from '@/lib/validation/parseLimit'
import { parseSearchText } from '@/lib/validation/parseSearchText'
import { parseTier } from '@/lib/validation/parseTier'

export const dynamic = 'force-dynamic'

export async function GET(request: Request): Promise<Response> {
  try {
    const { searchParams } = new URL(request.url)
    const search = parseSearchText(searchParams.get('search'))
    const tier = parseTier(searchParams.get('tier'))
    const limit = parseLimit(searchParams.get('limit'))
    return jsonResponse(await listCustomers(search, tier, limit))
  } catch (error) {
    return errorResponse(error)
  }
}
