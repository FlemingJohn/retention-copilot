import IconFrame from '@/components/IconFrame'

export default function TranscriptIcon({ size }: { size?: number }) {
  return (
    <IconFrame size={size}>
      <path d="M7 3.5h7.5L19 8v12a.5.5 0 0 1-.5.5H7a.5.5 0 0 1-.5-.5V4a.5.5 0 0 1 .5-.5z" />
      <path d="M14.5 3.5V8H19" />
      <path d="M9 12h6M9 15.5h6" />
    </IconFrame>
  )
}
