import ProfileScreen from '@/components/ProfileScreen'

export default async function CustomerPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  return <ProfileScreen customerId={id} />
}
