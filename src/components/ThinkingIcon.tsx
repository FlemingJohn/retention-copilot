import IconFrame from '@/components/IconFrame'

export default function ThinkingIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M9 17.5h6M10 20.5h4" />
      <path d="M12 3.5a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2v.6h5v-.6c0-.8.4-1.5 1-2A6 6 0 0 0 12 3.5z" />
    </IconFrame>
  )
}
