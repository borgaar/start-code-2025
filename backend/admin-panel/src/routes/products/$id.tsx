import { createFileRoute, Link, redirect } from '@tanstack/react-router'
import { getProductOptions } from '@/hooks/use-products'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowLeft } from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'

export const Route = createFileRoute('/products/$id')({
  component: ProductDetailPage,
  loader: async ({ params, context }) => {
    try {
      const data = await context.queryClient.ensureQueryData(
        getProductOptions(params.id),
      )
      return data
    } catch {
      throw redirect({
        to: '/products',
      })
    }
  },
  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading product...</div>
    </div>
  ),

  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading product: {error.message || 'Product not found'}
      </div>
    </div>
  ),
})

function ProductDetailPage() {
  const { id } = Route.useParams()
  const { data: product } = useSuspenseQuery(getProductOptions(id))

  return (
    <div className="p-8">
      <div className="mb-4">
        <Button variant="ghost" asChild>
          <Link to="/products">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Products
          </Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{product.name}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <h3 className="text-sm font-semibold text-gray-500">GTIN</h3>
              <p className="font-mono">{product.gtin}</p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">Price</h3>
              <p>${product.price.toFixed(2)}</p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">
                Price per Unit
              </h3>
              <p>
                ${product.pricePerUnit.toFixed(2)}/{product.unit}
              </p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">Unit</h3>
              <p>{product.unit}</p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">
                Carbon Footprint
              </h3>
              <p>{product.carbonFootprintGram}g CO₂</p>
            </div>
            <div>
              <h3 className="text-sm font-semibold text-gray-500">Type</h3>
              <div>
                {product.organic ? (
                  <Badge variant="secondary">Organic</Badge>
                ) : (
                  <Badge variant="outline">Regular</Badge>
                )}
              </div>
            </div>
          </div>

          <div>
            <h3 className="text-sm font-semibold text-gray-500 mb-2">
              Description
            </h3>
            <p className="text-sm">{product.description}</p>
          </div>

          {product.allergens && product.allergens.length > 0 && (
            <div>
              <h3 className="text-sm font-semibold text-gray-500 mb-2">
                Allergens
              </h3>
              <div className="flex flex-wrap gap-2">
                {product.allergens.map((allergen) => (
                  <Badge key={allergen} variant="destructive">
                    {allergen}
                  </Badge>
                ))}
              </div>
            </div>
          )}

          <div className="grid grid-cols-2 gap-4 text-xs text-gray-500">
            <div>
              <span className="font-semibold">Created: </span>
              {new Date(product.createdAt).toLocaleString()}
            </div>
            <div>
              <span className="font-semibold">Updated: </span>
              {new Date(product.updatedAt).toLocaleString()}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
