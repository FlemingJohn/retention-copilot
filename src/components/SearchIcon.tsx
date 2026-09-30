import IconFrame from '@/components/IconFrame'

export default function SearchIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <circle cx="11" cy="11" r="6.5" />
      <line x1="16" y1="16" x2="20.5" y2="20.5" />
    </IconFrame>
  )
}
