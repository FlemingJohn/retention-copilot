import { mapCustomerSummary } from '@/lib/queries/mapCustomerSummary'
import { readNullableNumber, readNullableText, readNumber, readText } from '@/lib/queries/rowReaders'
import type { CustomerProfile } from '@/types/CustomerProfile'
import type { SnowflakeRow } from '@/types/SnowflakeRow'

function readDrivers(row: SnowflakeRow): string[] {
  return ['TOP_DRIVER_1', 'TOP_DRIVER_2', 'TOP_DRIVER_3']
    .map((key) => readText(row, key))
    .filter((driver) => driver !== '')
}

export function mapCustomerProfile(row: SnowflakeRow): CustomerProfile {
  return {
    ...mapCustomerSummary(row),
    state: readText(row, 'STATE'),
    tenureMonths: readNumber(row, 'TENURE_MONTHS'),
    activePolicies: readNumber(row, 'ACTIVE_POLICIES'),
    totalMonthlyPremium: readNumber(row, 'TOTAL_MONTHLY_PREMIUM'),
    productsHeld: readNullableText(row, 'PRODUCTS_HELD'),
    latePayments: readNumber(row, 'LATE_PAYMENTS'),
    failedPayments: readNumber(row, 'FAILED_PAYMENTS'),
    lateOrFailedRate: readNullableNumber(row, 'LATE_OR_FAILED_RATE'),
    claimsCount: readNumber(row, 'CLAIMS_COUNT'),
    openClaims: readNumber(row, 'OPEN_CLAIMS'),
    rejectedClaims: readNumber(row, 'REJECTED_CLAIMS'),
    ticketsCount: readNumber(row, 'TICKETS_COUNT'),
    openTickets: readNumber(row, 'OPEN_TICKETS'),
    escalatedTickets: readNumber(row, 'ESCALATED_TICKETS'),
    averageSatisfaction: readNullableNumber(row, 'AVERAGE_SATISFACTION'),
    callsCount: readNumber(row, 'CALLS_COUNT'),
    averageSentiment: readNullableNumber(row, 'AVERAGE_SENTIMENT'),
    negativeCalls: readNumber(row, 'NEGATIVE_CALLS'),
    rivalMentions: readNumber(row, 'RIVAL_MENTIONS'),
    cancelIntentCalls: readNumber(row, 'CANCEL_INTENT_CALLS'),
    drivers: readDrivers(row),
    actionId: readNullableText(row, 'ACTION_ID'),
    actionChannel: readNullableText(row, 'ACTION_CHANNEL'),
    actionReason: readNullableText(row, 'ACTION_REASON'),
    draftMessage: readNullableText(row, 'DRAFT_MESSAGE'),
  }
}
