import { createFileRoute, Link, redirect } from '@tanstack/react-router'
import {
  useRemoveItemFromList,
  useUpdateItemInList,
  getShoppingListOptions,
} from '@/hooks/use-shopping-lists'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { ArrowLeft, Trash2, Plus } from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'

export const Route = createFileRoute('/shopping-lists/$id')({
  component: ShoppingListDetailPage,
  loader: async ({ params, context }) => {
    try {
      const data = await context.queryClient.ensureQueryData(
        getShoppingListOptions(params.id),
      )
      return data
    } catch {
      throw redirect({
        to: '/shopping-lists',
      })
    }
  },

  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading shopping list...</div>
    </div>
  ),

  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading shopping list: {error?.message || 'List not found'}
      </div>
    </div>
  ),
})

function ShoppingListDetailPage() {
  const { id } = Route.useParams()
  const { data: list } = useSuspenseQuery(getShoppingListOptions(id))
  const removeItem = useRemoveItemFromList()
  const updateItem = useUpdateItemInList()

  const handleRemoveItem = (itemId: string) => {
    if (confirm('Are you sure you want to remove this item?')) {
      removeItem.mutate({ id, itemId })
    }
  }

  const handleToggleChecked = (itemId: string) => {
    updateItem.mutate({ id, itemId })
  }

  const totalPrice = list.items.reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0,
  )

  return (
    <div className="p-8">
      <div className="mb-4">
        <Button variant="ghost" asChild>
          <Link to="/shopping-lists">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Shopping Lists
          </Link>
        </Button>
      </div>

      <Card className="mb-6">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>{list.name}</CardTitle>
            <p className="text-sm text-gray-500 mt-1">
              {list.items.length} items • Total: ${totalPrice.toFixed(2)}
            </p>
          </div>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Add Item
          </Button>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">Checked</TableHead>
                <TableHead>Product</TableHead>
                <TableHead>Quantity</TableHead>
                <TableHead>Price</TableHead>
                <TableHead>Total</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {list.items.map((item) => (
                <TableRow
                  key={item.id}
                  className={item.checked ? 'opacity-50' : ''}
                >
                  <TableCell>
                    <input
                      type="checkbox"
                      checked={item.checked}
                      onChange={() => handleToggleChecked(item.id)}
                      className="h-4 w-4"
                    />
                  </TableCell>
                  <TableCell>
                    <div>
                      <div className="font-medium">{item.product.name}</div>
                      <div className="text-sm text-gray-500">
                        {item.product.unit}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>{item.quantity}</TableCell>
                  <TableCell>${item.product.price.toFixed(2)}</TableCell>
                  <TableCell>
                    ${(item.product.price * item.quantity).toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleRemoveItem(item.id)}
                      disabled={removeItem.isPending}
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
    </div>
  )
}
