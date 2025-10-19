# Backend API

Et moderne REST API bygget med Hono, Prisma ORM, PostgreSQL, Zod-validering og OpenAPI-dokumentasjon.

## Oppsett

1. Installer avhengigheter:

```bash
pnpm install
```

2. Sett opp databasetilkoblingen i `.env`:

```
DATABASE_URL="postgresql://BRUKER:PASSORD@VERT:PORT/DATABASE?schema=public"
```

3. Push skjemaet til databasen:

```bash
pnpm run db:push
```

Eller opprett en migrasjon:

```bash
pnpm run db:migrate
```

4. (Valgfritt) Seed databasen med eksempeldata:

```bash
pnpm run db:seed
```

## Utvikling

Start utviklingsserveren:

```bash
pnpm dev
```

Serveren vil være tilgjengelig på:

- API: http://localhost:3000
- API-dokumentasjon (Scalar): http://localhost:3000/docs

## Tilgjengelige Skript

- `pnpm run dev` - Start utviklingsserver med hot reload
- `pnpm run build` - Bygg for produksjon
- `pnpm run start` - Start produksjonsserver
- `pnpm run db:generate` - Generer Prisma Client
- `pnpm run db:push` - Push skjemaendringer til database (ingen migrasjon)
- `pnpm run db:migrate` - Opprett og kjør migrasjoner
- `pnpm run db:studio` - Åpne Prisma Studio (database-GUI)
- `pnpm run db:seed` - Seed databasen med eksempeldata

## API-dokumentasjon

Alle endepunkter er dokumentert med OpenAPI/Swagger og inkluderer:

- **Zod-validering** for forespørsels-/responsskjemaer
- **Automatisk typeinferens** for TypeScript
- **Interaktiv API-dokumentasjon** via Scalar

Besøk http://localhost:3000/docs for å utforske API-et interaktivt.

### Tilgjengelige Endepunkter

**Produkter**

- `GET /products` - List alle produkter (støtter filtrering og paginering)
- `GET /products/{id}` - Hent et enkelt produkt via ID
- `POST /products` - Opprett et nytt produkt
- `PATCH /products/{id}` - Oppdater et produkt
- `DELETE /products/{id}` - Slett et produkt (soft delete)

### Query-parametere

**GET /products** støtter:

- `category` - Filtrer etter kategori
- `isActive` - Filtrer etter aktiv status (true/false)
- `limit` - Begrens antall resultater
- `offset` - Hopp over antall resultater

### Eksempel: Opprett et Produkt

```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Testprodukt",
    "description": "Et testprodukt",
    "price": 29.99,
    "stock": 10,
    "sku": "TEST-001",
    "category": "Test"
  }'
```

### Eksempel: List Produkter med Filtre

```bash
curl "http://localhost:3000/products?category=Elektronikk&isActive=true&limit=10"
```

### Eksempel: Oppdater et Produkt

```bash
curl -X PATCH http://localhost:3000/products/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "price": 24.99,
    "stock": 15
  }'
```

## Utviklingsguide

### Opprette Nye Endepunkter

1. **Definer Zod-skjemaer** i `src/schemas/`
2. **Opprett OpenAPI-ruter** i `src/routes/`
3. **Implementer handlere** i `src/handlers/`
4. **Registrer handlere** i `src/index.ts`

### Eksempel: Legge til et Nytt Endepunkt

```typescript
// 1. Opprett skjema (src/schemas/product.schema.ts)
export const CreateProductSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
  // ... flere felter
});

// 2. Opprett rute (src/routes/products.routes.ts)
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
      description: "Produkt opprettet",
    },
  },
});

// 3. Opprett handler (src/handlers/products.handlers.ts)
app.openapi(createProductRoute, async (c) => {
  const db = c.get("db");
  const body = c.req.valid("json");

  const product = await db.product.create({ data: body });
  return c.json(product, 201);
});
```

### Tilgang til Database i Endepunkter

Prisma-klienten er tilgjengelig i alle endepunkter via Hono-konteksten:

```typescript
app.openapi(someRoute, async (c) => {
  const db = c.get("db");
  const products = await db.product.findMany();
  return c.json(products);
});
```
