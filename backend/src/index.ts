import { serve } from "@hono/node-server";
import { Hono } from "hono";
import type { PrismaClient } from "@prisma/client";
import { prisma } from "./db.js";

type Variables = {
  db: PrismaClient;
};

const app = new Hono<{ Variables: Variables }>();

// Middleware to add Prisma client to context
app.use("*", async (c, next) => {
  c.set("db", prisma);
  await next();
});

app.get("/", (c) => {
  return c.text("Hello Hono!");
});

// Example endpoint to get all products
app.get("/products", async (c) => {
  const db = c.get("db");
  const products = await db.product.findMany({
    where: { isActive: true },
    orderBy: { createdAt: "desc" },
  });
  return c.json(products);
});

// Example endpoint to get a single product
app.get("/products/:id", async (c) => {
  const db = c.get("db");
  const id = c.req.param("id");
  const product = await db.product.findUnique({
    where: { id },
  });

  if (!product) {
    return c.json({ error: "Product not found" }, 404);
  }

  return c.json(product);
});

// Example endpoint to create a product
app.post("/products", async (c) => {
  const db = c.get("db");
  const body = await c.req.json();

  const product = await db.product.create({
    data: {
      name: body.name,
      description: body.description,
      price: body.price,
      stock: body.stock,
      sku: body.sku,
      category: body.category,
      imageUrl: body.imageUrl,
      isActive: body.isActive ?? true,
    },
  });

  return c.json(product, 201);
});

serve(
  {
    fetch: app.fetch,
    port: 3000,
  },
  (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
  }
);
