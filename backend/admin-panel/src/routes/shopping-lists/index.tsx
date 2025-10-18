import { createFileRoute, Link } from '@tanstack/react-router'
import {
  useCreateShoppingList,
  useDeleteShoppingList,
  getShoppingListsOptions,
} from '@/hooks/use-shopping-lists'
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
import { Plus, ExternalLink, Trash2 } from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'

export const Route = createFileRoute('/shopping-lists/')({
  component: ShoppingListsPage,
  loader: async ({ context }) => {
    return await context.queryClient.ensureQueryData(getShoppingListsOptions())
  },
  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading shopping lists...</div>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading shopping lists: {error.message}
      </div>
    </div>
  ),
})

function ShoppingListsPage() {
  const { data: lists } = useSuspenseQuery(getShoppingListsOptions())
  const createList = useCreateShoppingList()
  const deleteList = useDeleteShoppingList()

  const handleCreateList = () => {
    const name = prompt('Enter the name of the shopping list')
    if (!name) return
    createList.mutate(name)
  }

  const handleDeleteList = (id: string) => {
    if (confirm('Are you sure you want to delete this shopping list?')) {
      deleteList.mutate(id)
    }
  }

  return (
    <div className="p-8">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Shopping Lists</CardTitle>
          <Button onClick={handleCreateList} disabled={createList.isPending}>
            <Plus className="mr-2 h-4 w-4" />
            {createList.isPending ? 'Creating...' : 'New List'}
          </Button>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Created</TableHead>
                <TableHead>Last Updated</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {lists?.map((list) => (
                <TableRow key={list.id}>
                  <TableCell className="font-medium">{list.name}</TableCell>
                  <TableCell>
                    {new Date(list.createdAt).toLocaleDateString()}
                  </TableCell>
                  <TableCell>
                    {new Date(list.updatedAt).toLocaleDateString()}
                  </TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Button variant="ghost" size="sm" asChild>
                        <Link to="/shopping-lists/$id" params={{ id: list.id }}>
                          <ExternalLink className="h-4 w-4" />
                        </Link>
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleDeleteList(list.id)}
                        disabled={deleteList.isPending}
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
