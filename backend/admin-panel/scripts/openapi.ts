/* eslint-disable no-console */
import crypto from 'crypto'
import dotenv from 'dotenv'
import fs from 'node:fs'
import openAPI, { astToString } from 'openapi-typescript'
import z from 'zod'
import ts from 'typescript'

dotenv.config()

const { VITE_OPENAPI_URL: OPENAPI_URL } = z
  .object({
    VITE_OPENAPI_URL: z.url({
      error: '❌ Missing VITE_OPENAPI_URL environment variable.',
    }),
  })
  .parse(process.env)

const OUTPUT_PATH = 'src/schemas/openapi.schema.d.ts'
const INTERVAL_MS = 2000

const BLOB = ts.factory.createTypeReferenceNode(
  ts.factory.createIdentifier('Blob'),
)
const NULL = ts.factory.createLiteralTypeNode(ts.factory.createNull())

async function getSchema() {
  const ast = await openAPI(new URL(OPENAPI_URL), {
    transform(schemaObject) {
      if (schemaObject.format === 'binary') {
        return {
          schema: schemaObject.nullable
            ? ts.factory.createUnionTypeNode([BLOB, NULL])
            : BLOB,
          questionToken: true,
        }
      }

      return undefined
    },
  })
  return astToString(ast)
}

let lastHash = ''

async function checkForChanges() {
  try {
    const schema = await getSchema()
    const hash = crypto.createHash('sha256').update(schema).digest('hex')
    if (hash === lastHash) return
    lastHash = hash

    console.log('🔄 OpenAPI schema changed. Regenerating types...')

    fs.writeFileSync(OUTPUT_PATH, schema)
    console.log('✅ Types regenerated successfully.')
  } catch (error) {
    console.error('❌ Failed to check for changes:', error)
  }
}

;(async () => {
  console.log(`📄 Outputting TypeScript types to: ${OUTPUT_PATH}`)

  await checkForChanges()

  if (process.argv.includes('--watch')) {
    console.log(`👀 Watching OpenAPI schema at: ${OPENAPI_URL}`)
    console.log(`🔁 Check interval: ${INTERVAL_MS}ms`)
    setInterval(checkForChanges, INTERVAL_MS)
  }
})()
