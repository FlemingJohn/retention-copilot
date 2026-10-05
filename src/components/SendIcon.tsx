import IconFrame from '@/components/IconFrame'

export default function SendIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M4 12L20 4l-5 16-3.5-6.5L4 12z" />
      <path d="M11.5 13.5L20 4" />
    </IconFrame>
  )
}
