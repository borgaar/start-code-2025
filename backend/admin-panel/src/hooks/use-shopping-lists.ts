import {
  queryOptions,
  useMutation,
  useQueryClient,
} from '@tanstack/react-query'
import { client } from '@/lib/api'

export function getShoppingListsOptions() {
  return queryOptions({
    queryKey: ['shopping-lists'],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/shopping-lists')
      if (error) throw error
      return data
    },
  })
}

export function getShoppingListOptions(id: string) {
  return queryOptions({
    queryKey: ['shopping-lists', id],
    queryFn: async () => {
      const { data, error } = await client.GET('/api/shopping-lists/{id}', {
        params: { path: { id } },
      })
      if (error) throw error
      if (!data) throw new Error('Shopping list not found')
      return data
    },
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
      queryClient.invalidateQueries(getShoppingListsOptions())
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
      queryClient.invalidateQueries(getShoppingListsOptions())
      queryClient.invalidateQueries(getShoppingListOptions(id))
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
    onSuccess: (_, id) => {
      queryClient.invalidateQueries(getShoppingListsOptions())
      queryClient.invalidateQueries(getShoppingListOptions(id))
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
      queryClient.invalidateQueries(getShoppingListOptions(id))
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
      queryClient.invalidateQueries(getShoppingListOptions(id))
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
      queryClient.invalidateQueries(getShoppingListOptions(id))
    },
  })
}
