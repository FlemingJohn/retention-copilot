'use client'

import { useCallback, useEffect, useState } from 'react'

const storageKey = 'retention-copilot-sidebar-collapsed'

function saveChoice(isCollapsed: boolean): void {
  try {
    window.localStorage.setItem(storageKey, String(isCollapsed))
  } catch {
    return
  }
}

export function useSidebarState() {
  const [isCollapsed, setIsCollapsed] = useState(false)

  useEffect(() => {
    try {
      setIsCollapsed(window.localStorage.getItem(storageKey) === 'true')
    } catch {
      setIsCollapsed(false)
    }
  }, [])

  const toggle = useCallback(() => {
    setIsCollapsed((current) => {
      saveChoice(!current)
      return !current
    })
  }, [])

  return { isCollapsed, toggle }
}
