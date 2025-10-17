# Backend API

A modern REST API built with Hono, Prisma ORM, PostgreSQL, Zod validation, and OpenAPI documentation.

## Setup

1. Install dependencies:

```bash
pnpm install
```

2. Set up your database connection in `.env`:

```
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE?schema=public"
```

3. Push the schema to your database:

```bash
pnpm run db:push
```

Or create a migration:

```bash
pnpm run db:migrate
```

4. (Optional) Seed the database with sample data:

```bash
pnpm run db:seed
```

## Development

Start the development server:

```bash
pnpm run dev
```

The server will be available at:

- API: http://localhost:3000
- API Documentation (Scalar): http://localhost:3000/docs
- OpenAPI Spec: http://localhost:3000/openapi.json

## Available Scripts

- `pnpm run dev` - Start development server with hot reload
- `pnpm run build` - Build for production
- `pnpm run start` - Start production server
- `pnpm run db:generate` - Generate Prisma Client
- `pnpm run db:push` - Push schema changes to database (no migration)
- `pnpm run db:migrate` - Create and run migrations
- `pnpm run db:studio` - Open Prisma Studio (database GUI)
- `pnpm run db:seed` - Seed the database with sample data

## API Documentation

All endpoints are documented with OpenAPI/Swagger and include:

- **Zod validation** for request/response schemas
- **Automatic type inference** for TypeScript
- **Interactive API documentation** via Scalar

Visit http://localhost:3000/docs to explore the API interactively.

### Available Endpoints

**Products**

- `GET /products` - List all products (supports filtering and pagination)
- `GET /products/{id}` - Get a single product by ID
- `POST /products` - Create a new product
- `PATCH /products/{id}` - Update a product
- `DELETE /products/{id}` - Delete a product (soft delete)

### Query Parameters

**GET /products** supports:

- `category` - Filter by category
- `isActive` - Filter by active status (true/false)
- `limit` - Limit number of results
- `offset` - Skip number of results

### Example: Create a Product

```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "A test product",
    "price": 29.99,
    "stock": 10,
    "sku": "TEST-001",
    "category": "Test"
  }'
```

### Example: List Products with Filters

```bash
curl "http://localhost:3000/products?category=Electronics&isActive=true&limit=10"
```

### Example: Update a Product

```bash
curl -X PATCH http://localhost:3000/products/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "price": 24.99,
    "stock": 15
  }'
```

## Development Guide

### Creating New Endpoints

1. **Define Zod schemas** in `src/schemas/`
2. **Create OpenAPI routes** in `src/routes/`
3. **Implement handlers** in `src/handlers/`
4. **Register handlers** in `src/index.ts`

### Example: Adding a New Endpoint

```typescript
// 1. Create schema (src/schemas/product.schema.ts)
export const CreateProductSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
  // ... more fields
});

// 2. Create route (src/routes/products.routes.ts)
export const createProductRoute = createRoute({
  method: "post",
  path: "/products",
  request: {
    body: {
      content: {
        "application/json": {
          schema: CreateProductSchema,
        },
      },
    },
  },
  responses: {
    201: {
      content: {
        "application/json": {
          schema: ProductSchema,
        },
      },
      description: "Product created",
    },
  },
});

// 3. Create handler (src/handlers/products.handlers.ts)
app.openapi(createProductRoute, async (c) => {
  const db = c.get("db");
  const body = c.req.valid("json");

  const product = await db.product.create({ data: body });
  return c.json(product, 201);
});
```

### Accessing Database in Endpoints

The Prisma client is available in all endpoints via the Hono context:

```typescript
app.openapi(someRoute, async (c) => {
  const db = c.get("db");
  const products = await db.product.findMany();
  return c.json(products);
});
```

## Generating Frontend Types

You can generate TypeScript types for your frontend from the OpenAPI specification:

1. **Download the OpenAPI spec:**

```bash
curl http://localhost:3000/openapi.json > openapi.json
```

2. **Use a code generator** like:
   - [openapi-typescript](https://www.npmjs.com/package/openapi-typescript)
   - [openapi-typescript-codegen](https://www.npmjs.com/package/openapi-typescript-codegen)
   - Or use the Scalar docs to explore the API and manually create types

The OpenAPI spec includes all request/response schemas validated by Zod, ensuring type safety across your full stack.
