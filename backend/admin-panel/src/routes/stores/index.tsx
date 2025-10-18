import { createFileRoute, Link } from '@tanstack/react-router'
import {
  getStoresOptions,
  useCreateStore,
  useDeleteStore,
} from '@/hooks/use-stores'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Plus, ExternalLink, Trash2, MapPin } from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'

export const Route = createFileRoute('/stores/')({
  component: StoresPage,
  loader: async ({ context }) => {
    return await context.queryClient.ensureQueryData(getStoresOptions())
  },
  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading stores...</div>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading stores: {error.message}
      </div>
    </div>
  ),
})

function StoresPage() {
  const { data: stores } = useSuspenseQuery(getStoresOptions())
  const createStore = useCreateStore()
  const deleteStore = useDeleteStore()

  const handleCreateStore = () => {
    createStore.mutate()
  }

  const handleDeleteStore = (slug: string) => {
    if (confirm('Are you sure you want to delete this store?')) {
      deleteStore.mutate(slug)
    }
  }

  return (
    <div className="p-8">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Stores</CardTitle>
          <Button onClick={handleCreateStore} disabled={createStore.isPending}>
            <Plus className="mr-2 h-4 w-4" />
            {createStore.isPending ? 'Creating...' : 'New Store'}
          </Button>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Slug</TableHead>
                <TableHead>Created</TableHead>
                <TableHead>Last Updated</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {stores?.map((store) => (
                <TableRow key={store.slug}>
                  <TableCell className="font-medium">{store.name}</TableCell>
                  <TableCell className="font-mono text-sm">
                    {store.slug}
                  </TableCell>
                  <TableCell>
                    {new Date(store.createdAt).toLocaleDateString()}
                  </TableCell>
                  <TableCell>
                    {new Date(store.updatedAt).toLocaleDateString()}
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Button variant="ghost" size="sm" asChild>
                        <Link to="/stores/$slug" params={{ slug: store.slug }}>
                          <ExternalLink className="h-4 w-4" />
                        </Link>
                      </Button>
                      <Button variant="ghost" size="sm" asChild>
                        <Link
                          to="/stores/$slug/aisles"
                          params={{ slug: store.slug }}
                        >
                          <MapPin className="h-4 w-4" />
                        </Link>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleDeleteStore(store.slug)}
                        disabled={deleteStore.isPending}
                      >
                        <Trash2 className="h-4 w-4 text-red-500" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
