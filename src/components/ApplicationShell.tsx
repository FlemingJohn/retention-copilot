'use client'

import type { ReactNode } from 'react'
import DisclaimerFooter from '@/components/DisclaimerFooter'
import SideNavigation from '@/components/SideNavigation'
import TopBar from '@/components/TopBar'
import { useSidebarState } from '@/hooks/useSidebarState'
import styles from '@/components/ApplicationShell.module.css'

export default function ApplicationShell({ children }: { children: ReactNode }) {
  const { isCollapsed, toggle } = useSidebarState()
  return (
    <div className={styles.frame}>
      <TopBar />
      <div className={styles.body}>
        <SideNavigation isCollapsed={isCollapsed} onToggle={toggle} />
        <div className={styles.content}>
          <main className={styles.main}>{children}</main>
          <DisclaimerFooter />
        </div>
      </div>
    </div>
  )
}
