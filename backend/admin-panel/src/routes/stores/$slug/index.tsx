import { createFileRoute, Link } from '@tanstack/react-router'
import { useStore } from '@/hooks/use-stores'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowLeft, MapPin } from 'lucide-react'

export const Route = createFileRoute('/stores/$slug/')({
  component: StoreDetailPage,
})

function StoreDetailPage() {
  const { slug } = Route.useParams()
  const { data: store, isLoading, error } = useStore(slug)

  if (isLoading) {
    return (
      <div className="p-8">
        <div className="text-center">Loading store...</div>
      </div>
    )
  }

  if (error || !store) {
    return (
      <div className="p-8">
        <div className="text-center text-red-500">
          Error loading store: {error?.message || 'Store not found'}
        </div>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="mb-4 flex items-center justify-between">
        <Button variant="ghost" asChild>
          <Link to="/stores">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Stores
          </Link>
        </Button>
        <Button asChild>
          <Link to="/stores/$slug/aisles" params={{ slug }}>
            <MapPin className="mr-2 h-4 w-4" />
            View Aisles
          </Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{store.name}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <h3 className="text-sm font-semibold text-gray-500">Slug</h3>
              <p className="font-mono">{store.slug}</p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">Name</h3>
              <p>{store.name}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 text-xs text-gray-500">
            <div>
              <span className="font-semibold">Created: </span>
              {new Date(store.createdAt).toLocaleString()}
            </div>
            <div>
              <span className="font-semibold">Updated: </span>
              {new Date(store.updatedAt).toLocaleString()}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
