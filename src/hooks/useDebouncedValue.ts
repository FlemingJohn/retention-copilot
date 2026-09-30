'use client'

import { useEffect, useState } from 'react'

export function useDebouncedValue<T>(value: T, delayInMilliseconds: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedValue(value), delayInMilliseconds)
    return () => window.clearTimeout(timer)
  }, [value, delayInMilliseconds])

  return debouncedValue
}
