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
            schema: resolver(z.array(storeSchema)),
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
  zValidator("json", createStoreBodySchema),
  describeRoute({
    tags: ["store"],
    summary: "Create a new store",
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": { schema: resolver(storeSchema) },
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
          "application/json": { schema: resolver(storeWithAislesSchema) },
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
    responses: {
      200: {
        description: "Updated",
        content: {
          "application/json": { schema: resolver(storeSchema) },
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
        data: { name: body.name },
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
