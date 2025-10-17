import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { client } from '@/lib/api'

export function useShoppingLists() {
  return useQuery({
    queryKey: ['shopping-lists'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/shopping-lists')
      if (error) throw error
      return data
    },
  })
}

export function useShoppingList(id: string) {
  return useQuery({
    queryKey: ['shopping-lists', id],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/shopping-lists/{id}', {
        params: { path: { id } },
      })
      if (error) throw error
      return data
    },
    enabled: !!id,
  })
}

export function useCreateShoppingList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (name: string) => {
      const { data, error } = await client.POST('/api/shopping-lists', {
        body: {
          name,
        },
      })
      if (error) throw error
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists'] })
    },
  })
}

export function useUpdateShoppingList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      const { data, error } = await client.PATCH('/api/shopping-lists/{id}', {
        params: { path: { id } },
      })
      if (error) throw error
      return data
    },
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists'] })
      queryClient.invalidateQueries({ queryKey: ['shopping-lists', id] })
    },
  })
}

export function useDeleteShoppingList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await client.DELETE('/api/shopping-lists/{id}', {
        params: { path: { id } },
      })
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists'] })
    },
  })
}

export function useAddItemToList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      const { data, error } = await client.POST(
        '/api/shopping-lists/{id}/items',
        {
          params: { path: { id } },
        },
      )
      if (error) throw error
      return data
    },
    onSuccess: (_, id) => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists', id] })
    },
  })
}

export function useRemoveItemFromList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, itemId }: { id: string; itemId: string }) => {
      const { error } = await client.DELETE(
        '/api/shopping-lists/{id}/items/{itemId}',
        {
          params: { path: { id, itemId } },
        },
      )
      if (error) throw error
    },
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists', id] })
    },
  })
}

export function useUpdateItemInList() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, itemId }: { id: string; itemId: string }) => {
      const { data, error } = await client.PATCH(
        '/api/shopping-lists/{id}/items/{itemId}',
        {
          params: { path: { id, itemId } },
        },
      )
      if (error) throw error
      return data
    },
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['shopping-lists', id] })
    },
  })
}
