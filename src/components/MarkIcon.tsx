import IconFrame from '@/components/IconFrame'

export default function MarkIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <line x1="12" y1="3.5" x2="12" y2="20.5" />
      <line x1="4.6" y1="7.75" x2="19.4" y2="16.25" />
      <line x1="4.6" y1="16.25" x2="19.4" y2="7.75" />
    </IconFrame>
  )
}
