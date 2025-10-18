import { createFileRoute, Link, redirect } from '@tanstack/react-router'
import {
  getAislesOptions,
  getStoreOptions,
  useCreateAisle,
  useDeleteAisle,
} from '@/hooks/use-stores'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { ArrowLeft, Plus, Trash2 } from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'
import { cn } from '@/lib/utils'

export const Route = createFileRoute('/stores/$slug/aisles')({
  component: AislesPage,
  loader: async ({ params, context }) => {
    const store = await context.queryClient.ensureQueryData(
      getStoreOptions(params.slug),
    )
    if (!store) {
      throw redirect({
        to: '/stores',
      })
    }

    const aisles = await context.queryClient.ensureQueryData(
      getAislesOptions(params.slug),
    )

    return { store, aisles: aisles ?? [] }
  },

  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading aisles...</div>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading aisles: {error.message}
      </div>
    </div>
  ),
})

function AislesPage() {
  const { slug } = Route.useParams()

  const { data: store } = useSuspenseQuery(getStoreOptions(slug))
  const { data: aisles } = useSuspenseQuery(getAislesOptions(slug))
  const createAisle = useCreateAisle()
  const deleteAisle = useDeleteAisle()

  const handleCreateAisle = () => {
    createAisle.mutate(slug)
  }

  const handleDeleteAisle = (aisleId: string) => {
    if (confirm('Are you sure you want to delete this aisle?')) {
      deleteAisle.mutate({ slug, aisleId })
    }
  }

  return (
    <div className="p-8">
      <div className="mb-4">
        <Button variant="ghost" asChild>
          <Link to="/stores/$slug" params={{ slug }}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to {store?.name || 'Store'}
          </Link>
        </Button>
      </div>

      <Card className="mb-6">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Aisles - {store?.name}</CardTitle>
          <Button onClick={handleCreateAisle} disabled={createAisle.isPending}>
            <Plus className="mr-2 h-4 w-4" />
            {createAisle.isPending ? 'Creating...' : 'New Aisle'}
          </Button>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Type</TableHead>
                <TableHead>Position (X, Y)</TableHead>
                <TableHead>Size (W × H)</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {aisles?.map((aisle) => (
                <TableRow key={aisle.id}>
                  <TableCell>
                    <Badge
                      variant={
                        aisle.type === 'OBSTACLE' ? 'destructive' : 'secondary'
                      }
                    >
                      {aisle.type}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    ({aisle.gridX}, {aisle.gridY})
                  </TableCell>
                  <TableCell>
                    {aisle.width} × {aisle.height}
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDeleteAisle(aisle.id)}
                      disabled={deleteAisle.isPending}
                    >
                      <Trash2 className="h-4 w-4 text-red-500" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Grid Visualization */}
      <Card>
        <CardHeader>
          <CardTitle>Store Layout</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="relative bg-gray-100 p-4 rounded-lg overflow-auto">
            <div
              className="grid bg-[#434343]"
              style={{
                gridTemplateColumns: 'repeat(64, 10px)',
                gridTemplateRows: 'repeat(64, 10px)',
              }}
            >
              {aisles?.map((aisle) => (
                <div
                  key={aisle.id}
                  className="text-center relative"
                  style={{
                    gridColumnStart: aisle.gridX + 1,
                    gridColumnEnd: aisle.gridX + aisle.width + 1,
                    gridRowStart: aisle.gridY + 1,
                    gridRowEnd: aisle.gridY + aisle.height + 1,
                    backgroundColor:
                      aisle.type === 'OBSTACLE' ? '#2c2c2c' : '#6B6B6B',
                  }}
                >
                  {aisle.type != 'OBSTACLE' && (
                    <span
                      className={cn(
                        'absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2',
                        aisle.height > aisle.width + 1 && 'rotate-90',
                      )}
                    >
                      {aisle.type}
                    </span>
                  )}
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
