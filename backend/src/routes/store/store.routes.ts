import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";
import { StoreSchema, AisleSchema } from "~/generated/zod/schemas/models";

const storeSchema = StoreSchema;
const storeWithAislesSchema = StoreSchema.extend({
  aisles: z.array(AisleSchema),
});
const createStoreBodySchema = StoreSchema.omit({
  createdAt: true,
  updatedAt: true,
});
const updateStoreBodySchema = StoreSchema.omit({
  slug: true,
  createdAt: true,
  updatedAt: true,
}).partial();

const StoreTransferSchema = StoreSchema.omit({
  createdAt: true,
  updatedAt: true,
}).extend({
  updatedAt: z.string(),
  createdAt: z.string(),
});

const createStoreRequestBodyOpenAPI = await resolver(
  createStoreBodySchema.pick({
    name: true,
    slug: true,
  })
).toOpenAPISchema();

const updateStoreRequestBodyOpenAPI = await resolver(
  updateStoreBodySchema
).toOpenAPISchema();

// Get all stores
export const getAllStoresRoute = route().get(
  "/",
  describeRoute({
    tags: ["store"],
    summary: "Get all stores",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(StoreTransferSchema)),
          },
        },
      },
    },
  }),
  async (c) => {
    const stores = await c.get("db").store.findMany({
      orderBy: { name: "asc" },
    });
    return c.json(stores);
  }
);

// Create a new store
export const createStoreRoute = route().post(
  "/",
  zValidator(
    "json",
    createStoreBodySchema.pick({
      name: true,
      slug: true,
    })
  ),
  describeRoute({
    tags: ["store"],
    summary: "Create a new store",
    requestBody: {
      content: {
        "application/json": {
          schema: createStoreRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": {
            schema: resolver(StoreTransferSchema),
          },
        },
      },
      400: {
        description: "Invalid request body",
      },
      409: {
        description: "Store with this ID already exists",
      },
    },
  }),
  async (c) => {
    const body = c.req.valid("json");

    try {
      const store = await c.get("db").store.create({
        data: {
          slug: body.slug,
          name: body.name,
          entranceX: 50,
          entranceY: 62,
          exitX: 10,
          exitY: 62,
        },
      });

      return c.json(store, 201);
    } catch (error) {
      const errorMessage = String(error);
      if (errorMessage.includes("Unique constraint")) {
        return c.json({ error: "Store with this slug already exists" }, 409);
      }
      return c.json({ error: "Failed to create store" }, 400);
    }
  }
);

// Get a store by slug/id
export const getStoreBySlugRoute = route().get(
  "/:slug",
  describeRoute({
    tags: ["store"],
    summary: "Get a store by slug/id",
    responses: {
      200: {
        description: "Store found",
        content: {
          "application/json": { schema: resolver(StoreTransferSchema) },
        },
      },
      404: {
        description: "Store not found",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();
    const store = await c.get("db").store.findUnique({
      where: { slug },
      include: {
        aisles: {
          orderBy: [{ gridX: "asc" }, { gridY: "asc" }],
        },
      },
    });

    if (!store) {
      return c.json({ error: "Store not found" }, 404);
    }

    return c.json(store);
  }
);

// Update a store
export const updateStoreRoute = route().put(
  "/:slug",
  zValidator("json", updateStoreBodySchema),
  describeRoute({
    tags: ["store"],
    summary: "Update a store",
    requestBody: {
      content: {
        "application/json": {
          schema: updateStoreRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      200: {
        description: "Updated",
        content: {
          "application/json": { schema: resolver(StoreTransferSchema) },
        },
      },
      404: {
        description: "Store not found",
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();
    const body = c.req.valid("json");

    try {
      const store = await c.get("db").store.update({
        where: { slug },
        data: { ...body },
      });

      return c.json(store);
    } catch (error) {
      return c.json({ error: "Store not found" }, 404);
    }
  }
);

// Delete a store
export const deleteStoreRoute = route().delete(
  "/:slug",
  describeRoute({
    tags: ["store"],
    summary: "Delete a store",
    responses: {
      204: {
        description: "Deleted",
      },
      404: {
        description: "Store not found",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();

    try {
      await c.get("db").store.delete({
        where: { slug },
      });

      return c.body(null, 204);
    } catch (error) {
      return c.json({ error: "Store not found" }, 404);
    }
  }
);

export const getStoreItemAisleLocation = route().get(
  "/:slug/item/:itemId/aisle",
  describeRoute({
    tags: ["store"],
    summary: "Get the aisle location of an item",
    responses: {
      200: {
        description: "Aisle location found for item",
        content: {
          "application/json": {
            schema: resolver(z.object({ aisle: AisleSchema })),
          },
        },
      },
      404: {
        description: "Item or store not found",
        content: {
          "application/json": {
            schema: resolver(
              z.object({
                error: z
                  .literal("Store not found")
                  .or(z.literal("Item not found in any store aisle")),
              })
            ),
          },
        },
      },
    },
  }),
  async (c) => {
    const { slug, itemId } = c.req.param();
    const item = await c.get("db").product.findUnique({
      where: { productId: itemId },
    });

    if (!item) {
      return c.json({ error: "Item not found" }, 404);
    }

    const store = await c.get("db").store.findUnique({
      where: { slug },
    });

    if (!store) {
      return c.json({ error: "Store not found" }, 404);
    }
    const aisle = await c.get("db").aisle.findFirst({
      where: {
        storeSlug: slug,
        ProductInAisle: {
          some: { productId: itemId },
        },
      },
    });
    if (!aisle) {
      return c.json({ error: "Item not found in any store aisle" }, 404);
    }

    return c.json({ aisle });
  }
);

export const distributeProductsRoute = route().post(
  "/:slug/distribute-products",
  describeRoute({
    tags: ["store"],
    summary: "Evenly distribute products across aisles by type",
    responses: {
      200: {
        description: "Products distributed successfully",
        content: {
          "application/json": {
            schema: resolver(
              z.object({
                message: z.string(),
                distributedCount: z.number(),
              })
            ),
          },
        },
      },
      404: {
        description: "Store not found",
      },
      500: {
        description: "Failed to distribute products",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();
    const db = c.get("db");

    // Verify store exists
    const store = await db.store.findUnique({
      where: { slug },
    });

    if (!store) {
      return c.json({ error: "Store not found" }, 404);
    }

    try {
      // Get all products
      const products = await db.product.findMany();

      // Get all aisles for this store
      const aisles = await db.aisle.findMany({
        where: { storeSlug: slug },
      });

      if (aisles.length === 0) {
        return c.json({ error: "No aisles found in this store" }, 400);
      }

      // Clear existing product-aisle associations for this store
      await db.productInAisle.deleteMany({
        where: {
          aisle: {
            storeSlug: slug,
          },
        },
      });

      // Group aisles by type
      type AisleWithProducts = { id: string; products: typeof products };
      const aislesByType: Record<string, AisleWithProducts[]> = {};

      for (const aisle of aisles) {
        if (!aislesByType[aisle.type]) {
          aislesByType[aisle.type] = [];
        }
        const aisleTypeArray = aislesByType[aisle.type];
        if (aisleTypeArray) {
          aisleTypeArray.push({ id: aisle.id, products: [] });
        }
      }

      // Distribute products to aisles based on their type
      for (const product of products) {
        const matchingAisles = aislesByType[product.aisleType];

        if (!matchingAisles || matchingAisles.length === 0) {
          continue;
        }

        // Find the aisle with the least products to keep distribution even
        const aisleToAppend = matchingAisles.sort(
          (a, b) => a.products.length - b.products.length
        )[0];

        if (aisleToAppend) {
          aisleToAppend.products.push(product);
        }
      }

      // Create ProductInAisle entries
      const entriesToCreate: { aisleId: string; productId: string }[] = [];

      for (const aisles of Object.values(aislesByType)) {
        for (const aisle of aisles) {
          for (const product of aisle.products) {
            entriesToCreate.push({
              aisleId: aisle.id,
              productId: product.productId,
            });
          }
        }
      }

      if (entriesToCreate.length > 0) {
        await db.productInAisle.createMany({
          data: entriesToCreate,
        });
      }

      return c.json({
        message: "Products distributed successfully",
        distributedCount: entriesToCreate.length,
      });
    } catch (error) {
      console.error("Failed to distribute products:", error);
      return c.json({ error: "Failed to distribute products" }, 500);
    }
  }
);
