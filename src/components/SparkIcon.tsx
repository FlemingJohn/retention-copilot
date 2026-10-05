import IconFrame from '@/components/IconFrame'

export default function SparkIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M12 3.5l1.9 5.6 5.6 1.9-5.6 1.9L12 18.5l-1.9-5.6-5.6-1.9 5.6-1.9L12 3.5z" />
      <path d="M19 3.5v3M17.5 5h3" />
    </IconFrame>
  )
}
