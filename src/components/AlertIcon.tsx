import IconFrame from '@/components/IconFrame'

export default function AlertIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M12 4l9 16H3z" />
      <line x1="12" y1="10" x2="12" y2="14" />
      <line x1="12" y1="17" x2="12" y2="17.2" />
    </IconFrame>
  )
}
