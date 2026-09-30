import chipStyles from '@/components/Chip.module.css'

export default function ToolChip({ name }: { name: string }) {
  return <span className={`${chipStyles.chip} ${chipStyles.quiet}`}>Used {name}</span>
}
