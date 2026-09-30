import { Suspense } from 'react'
import AskScreen from '@/components/AskScreen'
import LoadingState from '@/components/LoadingState'

export default function AskPage() {
  return (
    <Suspense fallback={<LoadingState label="Loading" />}>
      <AskScreen />
    </Suspense>
  )
}
