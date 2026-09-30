import IconFrame from '@/components/IconFrame'

export default function AskIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M5 4.5h14a1.5 1.5 0 0 1 1.5 1.5v9a1.5 1.5 0 0 1-1.5 1.5H10l-4.5 3.5V16.5H5A1.5 1.5 0 0 1 3.5 15V6A1.5 1.5 0 0 1 5 4.5z" />
      <path d="M8.5 9.5h7M8.5 12.5h4" />
    </IconFrame>
  )
}
