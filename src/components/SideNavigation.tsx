'use client'

import { usePathname } from 'next/navigation'
import AskIcon from '@/components/AskIcon'
import CollapseButton from '@/components/CollapseButton'
import CustomersIcon from '@/components/CustomersIcon'
import NavigationItem from '@/components/NavigationItem'
import OverviewIcon from '@/components/OverviewIcon'
import styles from '@/components/SideNavigation.module.css'

const destinations = [
  { href: '/', label: 'Overview', icon: <OverviewIcon /> },
  { href: '/customers', label: 'Customers', icon: <CustomersIcon /> },
  { href: '/ask', label: 'Ask', icon: <AskIcon /> },
]

function isCurrent(pathname: string, href: string): boolean {
  return href === '/' ? pathname === '/' : pathname.startsWith(href)
}

export default function SideNavigation({ isCollapsed, onToggle }: { isCollapsed: boolean; onToggle: () => void }) {
  const pathname = usePathname()
  return (
    <nav className={`${styles.panel} ${isCollapsed ? styles.collapsed : ''}`} aria-label="Main">
      <CollapseButton isCollapsed={isCollapsed} onToggle={onToggle} />
      {destinations.map((destination) => (
        <NavigationItem
          key={destination.href}
          href={destination.href}
          label={destination.label}
          icon={destination.icon}
          isActive={isCurrent(pathname, destination.href)}
        />
      ))}
    </nav>
  )
}
