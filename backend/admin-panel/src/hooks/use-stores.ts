import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { client } from '@/lib/api'

export function useStores() {
  return useQuery({
    queryKey: ['stores'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store')
      if (error) throw error
      return data
    },
  })
}

export function useStore(slug: string) {
  return useQuery({
    queryKey: ['stores', slug],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store/{slug}', {
        params: { path: { slug } },
      })
      if (error) throw error
      return data
    },
    enabled: !!slug,
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
      queryClient.invalidateQueries({ queryKey: ['stores'] })
    },
  })
}

export function useUpdateStore() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (slug: string) => {
      const { data, error } = await client.PUT('/api/store/{slug}', {
        params: { path: { slug } },
      })
      if (error) throw error
      return data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['stores'] })
      if (!data) return
      queryClient.invalidateQueries({ queryKey: ['stores', data.slug] })
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
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stores'] })
    },
  })
}

export function useAisles(slug: string) {
  return useQuery({
    queryKey: ['stores', slug, 'aisles'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store/{slug}/aisle', {
        params: { path: { slug } },
      })
      if (error) throw error
      return data
    },
    enabled: !!slug,
  })
}

export function useAisle(slug: string, aisleId: string) {
  return useQuery({
    queryKey: ['stores', slug, 'aisles', aisleId],
    queryFn: async () => {
      const { data, error } = await client.GET(
        '/api/store/{slug}/aisle/{aisleId}',
        {
          params: { path: { slug, aisleId } },
        },
      )
      if (error) throw error
      return data
    },
    enabled: !!slug && !!aisleId,
  })
}

export function useCreateAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (slug: string) => {
      const { data, error } = await client.POST('/api/store/{slug}/aisle', {
        params: { path: { slug } },
      })
      if (error) throw error
      return data
    },
    onSuccess: (_, slug) => {
      queryClient.invalidateQueries({ queryKey: ['stores', slug, 'aisles'] })
    },
  })
}

export function useUpdateAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({
      slug,
      aisleId,
    }: {
      slug: string
      aisleId: string
    }) => {
      const { data, error } = await client.PUT(
        '/api/store/{slug}/aisle/{aisleId}',
        {
          params: { path: { slug, aisleId } },
        },
      )
      if (error) throw error
      return data
    },
    onSuccess: (_, { slug, aisleId }) => {
      queryClient.invalidateQueries({ queryKey: ['stores', slug, 'aisles'] })
      queryClient.invalidateQueries({
        queryKey: ['stores', slug, 'aisles', aisleId],
      })
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
      queryClient.invalidateQueries({ queryKey: ['stores', slug, 'aisles'] })
    },
  })
}

export function useAisleTypes() {
  return useQuery({
    queryKey: ['aisle-types'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/store/aisle-types')
      if (error) throw error
      return data
    },
  })
}

export function useAisleProducts(slug: string, aisleId: string) {
  return useQuery({
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
    enabled: !!slug && !!aisleId,
  })
}

export function useAddProductToAisle() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async () => {
      const { data, error } = await client.POST('/api/store/product-in-aisle')
      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stores'] })
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
      const { error } = await client.DELETE(
        '/api/store/product-in-aisle/{productId}/{aisleId}',
        {
          params: { path: { productId, aisleId } },
        },
      )
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stores'] })
    },
  })
}
