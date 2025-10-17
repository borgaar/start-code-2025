import { createFileRoute, Link } from '@tanstack/react-router'
import {
  useAisles,
  useCreateAisle,
  useDeleteAisle,
  useStore,
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

export const Route = createFileRoute('/stores/$slug/aisles')({
  component: AislesPage,
})

function AislesPage() {
  const { slug } = Route.useParams()
  const { data: store } = useStore(slug)
  const { data: aisles, isLoading, error } = useAisles(slug)
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

  if (isLoading) {
    return (
      <div className="p-8">
        <div className="text-center">Loading aisles...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-8">
        <div className="text-center text-red-500">
          Error loading aisles: {error.message}
        </div>
      </div>
    )
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
              className="relative"
              style={{
                width: '100%',
                height: '600px',
                minWidth: '800px',
              }}
            >
              {aisles?.map((aisle) => (
                <div
                  key={aisle.id}
                  className={`absolute border-2 ${
                    aisle.type === 'OBSTACLE'
                      ? 'bg-red-200 border-red-400'
                      : 'bg-blue-200 border-blue-400'
                  } flex items-center justify-center text-xs font-semibold`}
                  style={{
                    left: `${aisle.gridX * 50}px`,
                    top: `${aisle.gridY * 50}px`,
                    width: `${aisle.width * 50}px`,
                    height: `${aisle.height * 50}px`,
                  }}
                >
                  {aisle.type}
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
