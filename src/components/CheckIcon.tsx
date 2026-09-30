import IconFrame from '@/components/IconFrame'

export default function CheckIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <circle cx="12" cy="12" r="8.5" />
      <polyline points="8.5,12.3 11,14.8 15.8,9.5" />
    </IconFrame>
  )
}
