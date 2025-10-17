# Backend API

A Hono-based backend with Prisma ORM and PostgreSQL.

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

Open http://localhost:3000

## Available Scripts

- `pnpm run dev` - Start development server with hot reload
- `pnpm run build` - Build for production
- `pnpm run start` - Start production server
- `pnpm run db:generate` - Generate Prisma Client
- `pnpm run db:push` - Push schema changes to database (no migration)
- `pnpm run db:migrate` - Create and run migrations
- `pnpm run db:studio` - Open Prisma Studio (database GUI)
- `pnpm run db:seed` - Seed the database with sample data

## API Endpoints

### Products

- `GET /products` - Get all active products
- `GET /products/:id` - Get a single product by ID
- `POST /products` - Create a new product

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

## Database Access in Endpoints

The Prisma client is available in all endpoints via the Hono context:

```typescript
app.get("/example", async (c) => {
  const db = c.get("db");
  const products = await db.product.findMany();
  return c.json(products);
});
```
