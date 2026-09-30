import type { ReactNode } from 'react'
import styles from '@/components/Button.module.css'

export default function Button({
  children,
  onClick,
  variant = 'primary',
  type = 'button',
  disabled = false,
}: {
  children: ReactNode
  onClick?: () => void
  variant?: 'primary' | 'secondary'
  type?: 'button' | 'submit'
  disabled?: boolean
}) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`${styles.button} ${variant === 'primary' ? styles.primary : styles.secondary}`}
    >
      {children}
    </button>
  )
}
