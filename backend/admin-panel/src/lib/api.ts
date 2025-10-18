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

// Typescript magic ;)
export type ResponseType<
  TPath extends keyof paths,
  TMethod extends keyof paths[TPath],
  TStatus extends keyof paths[TPath][TMethod] extends never
    ? never
    : paths[TPath][TMethod] extends { responses: infer R }
      ? keyof R
      : never,
> = paths[TPath][TMethod] extends { responses: infer R }
  ? TStatus extends keyof R
    ? R[TStatus] extends { content: infer C }
      ? C extends { 'application/json': infer J }
        ? J
        : never
      : never
    : never
  : never
