import IconFrame from '@/components/IconFrame'

export default function ChartIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M4 20h16" />
      <rect x="6" y="11" width="3" height="7" rx="0.8" />
      <rect x="10.5" y="6" width="3" height="12" rx="0.8" />
      <rect x="15" y="13" width="3" height="5" rx="0.8" />
    </IconFrame>
  )
}
