import IconFrame from '@/components/IconFrame'

export default function CustomersIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <circle cx="9" cy="8" r="3.2" />
      <path d="M3 19c0-3.2 2.7-5.2 6-5.2s6 2 6 5.2" />
      <circle cx="17.2" cy="9" r="2.5" />
      <path d="M16.5 14.2c2.8 0 4.5 1.5 4.5 4" />
    </IconFrame>
  )
}
