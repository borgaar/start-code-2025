import createClient from 'openapi-fetch'
import type { paths } from '@/schemas/openapi.schema'
import { z } from 'zod'

const { VITE_BASE_API_URL } = z
  .object({
    VITE_BASE_API_URL: z.url({
      error: '❌ Missing VITE_BASE_API_URL environment variable.',
    }),
  })
  .parse(import.meta.env)

export const client = createClient<paths>({
  baseUrl: VITE_BASE_API_URL,
})
