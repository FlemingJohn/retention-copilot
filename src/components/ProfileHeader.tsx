import Link from 'next/link'
import styles from '@/components/ProfileHeader.module.css'
import type { CustomerProfile } from '@/types/CustomerProfile'

export default function ProfileHeader({ profile }: { profile: CustomerProfile }) {
  return (
    <header className={styles.header}>
      <Link href="/customers" className={styles.back}>
        Back to customers
      </Link>
      <h1>{profile.firstName}</h1>
      <p className={styles.detail}>
        {profile.city}, {profile.state} · {profile.segment} · {profile.customerId}
      </p>
    </header>
  )
}
