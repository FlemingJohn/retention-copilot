import 'server-only'
import { mapCustomerProfile } from '@/lib/queries/mapCustomerProfile'
import { runStatement } from '@/lib/snowflake/runStatement'
import type { CustomerProfile } from '@/types/CustomerProfile'

export async function getCustomerProfile(customerId: string): Promise<CustomerProfile | null> {
  const rows = await runStatement('select * from CUSTOMER_OVERVIEW where customer_id = ?', [customerId])
  return rows.length === 0 ? null : mapCustomerProfile(rows[0])
}
