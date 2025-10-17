import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";
import { AisleSchema } from "~/generated/zod/schemas/models";
import { AisleTypeSchema } from "~/generated/zod/schemas/enums/AisleType.schema";

const aisleSchema = AisleSchema;
const createAisleBodySchema = AisleSchema.omit({
  id: true,
  storeSlug: true,
});
const updateAisleBodySchema = AisleSchema.omit({
  id: true,
  storeSlug: true,
}).partial();

// Get all aisles for a store
export const getAislesRoute = route().get(
  "/:slug/aisle",
  describeRoute({
    tags: ["aisle"],
    summary: "Get all aisles for a store",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(aisleSchema)),
          },
        },
      },
      404: {
        description: "Store not found",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();

    // Verify store exists
    const store = await c.get("db").store.findUnique({
      where: { slug },
    });

    if (!store) {
      return c.json({ error: "Store not found" }, 404);
    }

    const aisles = await c.get("db").aisle.findMany({
      where: { storeSlug: slug },
      orderBy: [{ gridX: "asc" }, { gridY: "asc" }],
    });

    return c.json(aisles);
  }
);

const createAisleRequestBodyOpenAPI = await resolver(
  createAisleBodySchema
).toOpenAPISchema();

const updateAisleRequestBodyOpenAPI = await resolver(
  updateAisleBodySchema
).toOpenAPISchema();

// Create a new aisle for a store
export const createAisleRoute = route().post(
  "/:slug/aisle",
  zValidator("json", createAisleBodySchema),
  describeRoute({
    tags: ["aisle"],
    summary: "Create a new aisle for a store",
    requestBody: {
      content: {
        "application/json": {
          schema: createAisleRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": { schema: resolver(aisleSchema) },
        },
      },
      400: {
        description: "Invalid request body",
      },
      404: {
        description: "Store not found",
      },
      409: {
        description: "Aisle with this ID already exists",
      },
    },
  }),
  async (c) => {
    const { slug } = c.req.param();
    const body = c.req.valid("json");

    // Verify store exists
    const store = await c.get("db").store.findUnique({
      where: { slug },
    });

    if (!store) {
      return c.json({ error: "Store not found" }, 404);
    }

    try {
      const aisle = await c.get("db").aisle.create({
        data: {
          type: body.type,
          gridX: body.gridX,
          gridY: body.gridY,
          width: body.width,
          height: body.height,
          storeSlug: slug,
        },
      });

      return c.json(aisle, 201);
    } catch (error) {
      return c.json({ error: "Failed to create aisle" }, 400);
    }
  }
);

// Get a specific aisle
export const getAisleRoute = route().get(
  "/:slug/aisle/:aisleId",
  describeRoute({
    tags: ["aisle"],
    summary: "Get a specific aisle",
    responses: {
      200: {
        description: "Aisle found",
        content: {
          "application/json": { schema: resolver(aisleSchema) },
        },
      },
      404: {
        description: "Aisle not found",
      },
    },
  }),
  async (c) => {
    const { slug, aisleId } = c.req.param();

    const aisle = await c.get("db").aisle.findFirst({
      where: {
        id: aisleId,
        storeSlug: slug,
      },
    });

    if (!aisle) {
      return c.json({ error: "Aisle not found" }, 404);
    }

    return c.json(aisle);
  }
);

// Update an aisle
export const updateAisleRoute = route().put(
  "/:slug/aisle/:aisleId",
  zValidator("json", updateAisleBodySchema),
  describeRoute({
    tags: ["aisle"],
    summary: "Update an aisle",
    requestBody: {
      content: {
        "application/json": {
          schema: updateAisleRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      200: {
        description: "Updated",
        content: {
          "application/json": { schema: resolver(aisleSchema) },
        },
      },
      404: {
        description: "Aisle not found",
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const { slug, aisleId } = c.req.param();
    const body = c.req.valid("json");

    try {
      const aisle = await c.get("db").aisle.updateMany({
        where: {
          id: aisleId,
          storeSlug: slug,
        },
        data: body,
      });

      if (aisle.count === 0) {
        return c.json({ error: "Aisle not found" }, 404);
      }

      // Fetch the updated aisle
      const updatedAisle = await c.get("db").aisle.findUnique({
        where: { id: aisleId },
      });

      return c.json(updatedAisle);
    } catch (error) {
      return c.json({ error: "Failed to update aisle" }, 400);
    }
  }
);

// Delete an aisle
export const deleteAisleRoute = route().delete(
  "/:slug/aisle/:aisleId",
  describeRoute({
    tags: ["aisle"],
    summary: "Delete an aisle",
    responses: {
      204: {
        description: "Deleted",
      },
      404: {
        description: "Aisle not found",
      },
    },
  }),
  async (c) => {
    const { slug, aisleId } = c.req.param();

    try {
      const result = await c.get("db").aisle.deleteMany({
        where: {
          id: aisleId,
          storeSlug: slug,
        },
      });

      if (result.count === 0) {
        return c.json({ error: "Aisle not found" }, 404);
      }

      return c.body(null, 204);
    } catch (error) {
      return c.json({ error: "Failed to delete aisle" }, 400);
    }
  }
);

// Get all aisle types
export const getAisleTypesRoute = route().get(
  "/aisle-types",
  describeRoute({
    tags: ["aisle"],
    summary: "Get all available aisle types",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(z.string())),
          },
        },
      },
    },
  }),
  async (c) => {
    const entries = Object.values(AisleTypeSchema.def.entries);
    return c.json(entries);
  }
);
