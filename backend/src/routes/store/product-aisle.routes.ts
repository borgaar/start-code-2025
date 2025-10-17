import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";
import {
  ProductInAisleSchema,
  ProductSchema,
} from "~/generated/zod/schemas/models";

const productInAisleSchema = ProductInAisleSchema;
const productInAisleWithProductSchema = ProductInAisleSchema.extend({
  product: ProductSchema.omit({
    createdAt: true,
    updatedAt: true,
  }).extend({
    updatedAt: z.string(),
    createdAt: z.string(),
  }),
});

const addProductToAisleBodySchema = ProductInAisleSchema.omit({
  id: true,
});

const addProductToAisleRequestBodyOpenAPI = await resolver(
  addProductToAisleBodySchema
).toOpenAPISchema();

// Add product to aisle
export const addProductToAisleRoute = route().post(
  "/product-in-aisle",
  zValidator("json", addProductToAisleBodySchema),
  describeRoute({
    tags: ["aisle"],
    summary: "Add a product to an aisle",
    requestBody: {
      content: {
        "application/json": {
          schema: addProductToAisleRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      201: {
        description: "Product added to aisle",
        content: {
          "application/json": {
            schema: resolver(productInAisleSchema),
          },
        },
      },
      400: {
        description: "Invalid request body",
      },
      404: {
        description: "Product or aisle not found",
      },
      409: {
        description: "Product already in this aisle",
      },
    },
  }),
  async (c) => {
    const body = c.req.valid("json");

    // Verify product exists
    const product = await c.get("db").product.findUnique({
      where: { productId: body.productId },
    });

    if (!product) {
      return c.json({ error: "Product not found" }, 404);
    }

    // Verify aisle exists
    const aisle = await c.get("db").aisle.findUnique({
      where: { id: body.aisleId },
    });

    if (!aisle) {
      return c.json({ error: "Aisle not found" }, 404);
    }

    try {
      const productInAisle = await c.get("db").productInAisle.create({
        data: {
          id: `${body.productId}_${body.aisleId}`,
          productId: body.productId,
          aisleId: body.aisleId,
        },
      });

      return c.json(productInAisle, 201);
    } catch (error) {
      const errorMessage = String(error);
      if (errorMessage.includes("Unique constraint")) {
        return c.json({ error: "Product already in this aisle" }, 409);
      }
      return c.json({ error: "Failed to add product to aisle" }, 400);
    }
  }
);

// Remove product from aisle
export const removeProductFromAisleRoute = route().delete(
  "/product-in-aisle/:productId/:aisleId",
  describeRoute({
    tags: ["aisle"],
    summary: "Remove a product from an aisle",
    responses: {
      204: {
        description: "Product removed from aisle",
      },
      404: {
        description: "Product-aisle association not found",
      },
    },
  }),
  async (c) => {
    const { productId, aisleId } = c.req.param();

    try {
      const result = await c.get("db").productInAisle.deleteMany({
        where: {
          productId,
          aisleId,
        },
      });

      if (result.count === 0) {
        return c.json({ error: "Product-aisle association not found" }, 404);
      }

      return c.body(null, 204);
    } catch (error) {
      return c.json({ error: "Failed to remove product from aisle" }, 400);
    }
  }
);

// Get products in an aisle
export const getProductsInAisleRoute = route().get(
  "/:slug/aisle/:aisleId/products",
  describeRoute({
    tags: ["aisle"],
    summary: "Get all products in an aisle",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(productInAisleWithProductSchema)),
          },
        },
      },
      404: {
        description: "Aisle not found",
      },
    },
  }),
  async (c) => {
    const { slug, aisleId } = c.req.param();

    // Verify aisle exists and belongs to store
    const aisle = await c.get("db").aisle.findFirst({
      where: {
        id: aisleId,
        storeSlug: slug,
      },
    });

    if (!aisle) {
      return c.json({ error: "Aisle not found" }, 404);
    }

    const productsInAisle = await c.get("db").productInAisle.findMany({
      where: { aisleId },
      include: {
        product: true,
      },
    });

    return c.json(productsInAisle);
  }
);
