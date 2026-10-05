import IconFrame from '@/components/IconFrame'

export default function DecisionIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <rect x="5.5" y="4.5" width="13" height="16" rx="2" />
      <path d="M9 4.5v-1h6v1" />
      <polyline points="9,13 11.2,15.2 15.2,10.8" />
    </IconFrame>
  )
}
