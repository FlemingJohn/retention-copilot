import { describeCount, describeOptionalNumber } from '@/lib/format/describeNumber'
import { formatPercent } from '@/lib/format/formatPercent'
import { formatRupees } from '@/lib/format/formatRupees'
import type { CustomerProfile } from '@/types/CustomerProfile'

export interface FactGroup {
  title: string
  facts: Array<{ label: string; value: string }>
}

export function buildFactGroups(profile: CustomerProfile): FactGroup[] {
  return [
    {
      title: 'Policies',
      facts: [
        { label: 'Active policies', value: String(profile.activePolicies) },
        { label: 'Products held', value: profile.productsHeld ?? 'None' },
        { label: 'Monthly premium', value: formatRupees(profile.totalMonthlyPremium) },
        { label: 'Time with us', value: describeCount(profile.tenureMonths, 'month') },
      ],
    },
    {
      title: 'Payments, last six months',
      facts: [
        { label: 'Late payments', value: String(profile.latePayments) },
        { label: 'Failed payments', value: String(profile.failedPayments) },
        { label: 'Late or failed share', value: formatPercent(profile.lateOrFailedRate) },
      ],
    },
    {
      title: 'Claims and service',
      facts: [
        { label: 'Claims filed', value: String(profile.claimsCount) },
        { label: 'Open or rejected claims', value: String(profile.openClaims + profile.rejectedClaims) },
        { label: 'Service tickets', value: String(profile.ticketsCount) },
        { label: 'Open or escalated tickets', value: String(profile.openTickets + profile.escalatedTickets) },
        { label: 'Average satisfaction', value: describeOptionalNumber(profile.averageSatisfaction) },
      ],
    },
    {
      title: 'Calls',
      facts: [
        { label: 'Calls', value: String(profile.callsCount) },
        { label: 'Average sentiment', value: describeOptionalNumber(profile.averageSentiment, 2) },
        { label: 'Negative calls', value: String(profile.negativeCalls) },
        { label: 'Rival insurer mentions', value: String(profile.rivalMentions) },
        { label: 'Wants to cancel', value: describeCount(profile.cancelIntentCalls, 'call') },
      ],
    },
  ]
}
