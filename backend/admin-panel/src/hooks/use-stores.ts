import {
  queryOptions,
  useMutation,
  useQueryClient,
} from '@tanstack/react-query'
import { client } from '@/lib/api'

import type { operations } from '@/schemas/openapi.schema'

type AisleTypes =
  operations['getApiResourcesAisle-types']['responses']['200']['content']['application/json'][number]

export function getStoresOptions() {
  return queryOptions({
    queryKey: ['stores'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store')
      if (error) throw error
      return data
    },
  })
}

export function getStoreOptions(slug: string) {
  return queryOptions({
    queryKey: ['stores', slug],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store/{slug}', {
        params: { path: { slug } },
      })
      if (error) throw error
      if (!data) throw new Error('Store not found')
      return data
    },
  })
}

export function useCreateStore() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async () => {
      const { data, error } = await client.POST('/api/store')
      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries(getStoresOptions())
    },
  })
}

export function useUpdateStore() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      slug,
      ...body
    }: {
      slug: string
      name?: string
      entranceX?: number
      entranceY?: number
      exitX?: number
      exitY?: number
    }) => {
      const { data, error } = await client.PUT('/api/store/{slug}', {
        params: { path: { slug } },
        body,
      })
      if (error) throw error
      return data
    },
    onSuccess: (_, { slug }) => {
      queryClient.invalidateQueries(getStoresOptions())
      queryClient.invalidateQueries(getStoreOptions(slug))
    },
  })
}

export function useDeleteStore() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (slug: string) => {
      const { error } = await client.DELETE('/api/store/{slug}', {
        params: { path: { slug } },
      })
      if (error) throw error
    },
    onSuccess: (_, slug) => {
      queryClient.invalidateQueries(getStoresOptions())
      queryClient.invalidateQueries(getStoreOptions(slug))
    },
  })
}

export function getAislesOptions(slug: string) {
  return queryOptions({
    queryKey: ['stores', slug, 'aisles'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store/{slug}/aisle', {
        params: { path: { slug } },
      })
      if (error) throw error
      return data
    },
  })
}

export function getAisleOptions(slug: string, aisleId: string) {
  return queryOptions({
    queryKey: ['stores', slug, 'aisles', aisleId],
    queryFn: async () => {
      const { data, error } = await client.GET(
        '/api/store/{slug}/aisle/{aisleId}',
        {
          params: { path: { slug, aisleId } },
        },
      )
      if (error) throw error
      if (!data) throw new Error('Aisle not found')
      return data
    },
  })
}

export function useCreateAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      slug,
      body,
    }: {
      slug: string
      body?: {
        type: AisleTypes
        gridX: number
        gridY: number
        width: number
        height: number
      }
    }) => {
      const { data, error } = await client.POST('/api/store/{slug}/aisle', {
        params: { path: { slug } },
        body,
      })
      if (error) throw error
      return data
    },
    onSuccess: (_, { slug }) => {
      queryClient.invalidateQueries(getAislesOptions(slug))
    },
  })
}

export function useUpdateAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      slug,
      aisleId,
      body,
    }: {
      slug: string
      aisleId: string
      body: {
        type?: AisleTypes
        gridX?: number
        gridY?: number
        width?: number
        height?: number
      }
    }) => {
      const { data, error } = await client.PUT(
        '/api/store/{slug}/aisle/{aisleId}',
        {
          params: { path: { slug, aisleId } },
          body,
        },
      )
      if (error) throw error
      return data
    },
    onSuccess: (_, { slug, aisleId }) => {
      queryClient.invalidateQueries(getAislesOptions(slug))
      queryClient.invalidateQueries(getAisleOptions(slug, aisleId))
    },
  })
}

export function useDeleteAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      slug,
      aisleId,
    }: {
      slug: string
      aisleId: string
    }) => {
      const { error } = await client.DELETE(
        '/api/store/{slug}/aisle/{aisleId}',
        {
          params: { path: { slug, aisleId } },
        },
      )
      if (error) throw error
    },
    onSuccess: (_, { slug }) => {
      queryClient.invalidateQueries(getAislesOptions(slug))
    },
  })
}

export function getAisleTypesOptions() {
  return queryOptions({
    queryKey: ['aisle-types'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/resources/aisle-types')
      if (error) throw error
      return data
    },
  })
}

export function getAisleProductsOptions(slug: string, aisleId: string) {
  return queryOptions({
    queryKey: ['stores', slug, 'aisles', aisleId, 'products'],
    queryFn: async () => {
      const { data, error } = await client.GET(
        '/api/store/{slug}/aisle/{aisleId}/products',
        {
          params: { path: { slug, aisleId } },
        },
      )
      if (error) throw error
      return data
    },
  })
}

export function useAddProductToAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      productId,
      aisleId,
    }: {
      productId: string
      aisleId: string
    }) => {
      const { data, error } = await client.POST('/api/store/product-in-aisle', {
        body: {
          aisleId,
          productId,
        },
      })
      if (error) throw error
      if (!data) throw new Error('Product not added to aisle')
      return data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries(
        getAislesWithProductsOptions(data.storeSlug),
      )
    },
  })
}

export function useRemoveProductFromAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      productId,
      aisleId,
    }: {
      productId: string
      aisleId: string
    }) => {
      const { data, error } = await client.DELETE(
        '/api/store/product-in-aisle/{productId}/{aisleId}',
        {
          params: { path: { productId, aisleId } },
          body: {
            aisleId,
            productId,
          },
        },
      )
      if (error) throw error
      if (!data) throw new Error('Product not added to aisle')
      return data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries(
        getAislesWithProductsOptions(data.storeSlug),
      )
    },
  })
}

export function getAislesWithProductsOptions(slug: string) {
  return queryOptions({
    queryKey: ['ailes-with-products', slug],
    queryFn: async () => {
      const { data, error } = await client.GET(
        '/api/store/{slug}/aisles-products',
        { params: { path: { slug } } },
      )

      if (error) throw error
      if (!data) throw new Error('Aisles with products not found')
      return data
    },
  })
}
