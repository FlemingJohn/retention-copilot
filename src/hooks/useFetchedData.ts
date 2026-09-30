'use client'

import { useCallback, useEffect, useState } from 'react'
import { readErrorMessage } from '@/lib/api/readErrorMessage'
import { readJsonOrThrow } from '@/lib/api/readJsonOrThrow'

export function useFetchedData<T>(url: string | null) {
  const [data, setData] = useState<T | null>(null)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(url !== null)
  const [reloadCount, setReloadCount] = useState(0)

  useEffect(() => {
    if (url === null) {
      setIsLoading(false)
      return undefined
    }
    const controller = new AbortController()
    setIsLoading(true)
    setErrorMessage(null)
    fetch(url, { signal: controller.signal })
      .then(readJsonOrThrow)
      .then((body) => setData(body as T))
      .catch((error: unknown) => {
        if (!controller.signal.aborted) {
          setErrorMessage(readErrorMessage(error))
        }
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          setIsLoading(false)
        }
      })
    return () => controller.abort()
  }, [url, reloadCount])

  const reload = useCallback(() => setReloadCount((count) => count + 1), [])
  return { data, setData, errorMessage, isLoading, reload }
}
