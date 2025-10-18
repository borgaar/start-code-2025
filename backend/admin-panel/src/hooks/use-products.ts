import { queryOptions } from '@tanstack/react-query'
import { client } from '@/lib/api'

export function getProductsOptions() {
  return queryOptions({
    queryKey: ['products'],
    queryFn: async () => {
      const response = await client.GET('/api/products')
      if (!response.response.ok || response.data == null)
        throw new Error('Failed to fetch products')
      return response.data
    },
  })
}

export function getProductOptions(id: string) {
  return queryOptions({
    queryKey: ['products', id],
    queryFn: async () => {
      const response = await client.GET('/api/products/{id}', {
        params: { path: { id } },
      })
      if (response.error) throw response.error
      if (!response.data) throw new Error('Product not found')
      return response.data
    },
  })
}
