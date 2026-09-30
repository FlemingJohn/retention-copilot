import IconFrame from '@/components/IconFrame'

export default function ChevronIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <polyline points="15,6 9,12 15,18" />
    </IconFrame>
  )
}
