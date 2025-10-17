import createClient from 'openapi-fetch'
import type { paths } from '@/schemas/openapi.schema'
import { z } from 'zod'

const { VITE_OPENAPI_URL } = z
  .object({
    VITE_OPENAPI_URL: z.url({
      error: '❌ Missing VITE_OPENAPI_URL environment variable.',
    }),
  })
  .parse(process.env)

export const client = createClient<paths>({
  baseUrl: VITE_OPENAPI_URL,
})
