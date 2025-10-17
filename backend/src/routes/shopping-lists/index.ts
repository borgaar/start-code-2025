import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";

const shoppingListItemSchema = z.object({
  id: z.string(),
  shoppingListId: z.string(),
  productId: z.string(),
  quantity: z.number(),
  checked: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string(),
  product: z.object({
    id: z.string(),
    productId: z.string(),
    gtin: z.string(),
    name: z.string(),
    description: z.string(),
    price: z.number(),
    pricePerUnit: z.number(),
    unit: z.string(),
    allergens: z.string().nullable(),
    carbonFootprintGram: z.number(),
    organic: z.boolean(),
  }),
});

const shoppingListSchema = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
  items: z.array(shoppingListItemSchema),
});

const shoppingListWithoutItemsSchema = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

const createShoppingListBodySchema = z.object({
  name: z.string().min(1, "Name is required"),
});

const addItemBodySchema = z.object({
  productId: z.string().min(1, "Product ID is required"),
  quantity: z.number().int().positive().default(1),
});

const updateItemBodySchema = z.object({
  quantity: z.number().int().positive().optional(),
  checked: z.boolean().optional(),
});

// Get all shopping lists
const getAllRoute = route().get(
  "/",
  describeRoute({
    tags: ["shopping-list"],
    summary: "Get all shopping lists",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(shoppingListWithoutItemsSchema)),
          },
        },
      },
    },
  }),
  async (c) => {
    const shoppingLists = await c.get("db").shoppingList.findMany({
      orderBy: { createdAt: "desc" },
    });
    return c.json(shoppingLists);
  }
);

// Create a new shopping list
const createRoute = route().post(
  "/",
  zValidator("json", createShoppingListBodySchema),
  describeRoute({
    tags: ["shopping-list"],
    summary: "Create a new shopping list",
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": { schema: resolver(shoppingListSchema) },
        },
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const body = c.req.valid("json");

    const shoppingList = await c.get("db").shoppingList.create({
      data: { name: body.name },
      include: { items: { include: { product: true } } },
    });

    return c.json(shoppingList, 201);
  }
);

// Get a shopping list by ID
const getByIdRoute = route().get(
  "/:id",
  describeRoute({
    tags: ["shopping-list"],
    summary: "Get a shopping list by ID",
    responses: {
      200: {
        description: "Shopping list found",
        content: {
          "application/json": { schema: resolver(shoppingListSchema) },
        },
      },
      404: {
        description: "Shopping list not found",
      },
    },
  }),
  async (c) => {
    console.log("getByIdRoute");
    const { id } = c.req.param();
    const shoppingList = await c.get("db").shoppingList.findUnique({
      where: { id },
      include: {
        items: {
          include: { product: true },
          orderBy: { createdAt: "asc" },
        },
      },
    });

    console.log(shoppingList);

    if (!shoppingList) {
      return c.json({ error: "Shopping list not found" }, 404);
    }

    return c.json(shoppingList);
  }
);

// Update a shopping list
const updateRoute = route().patch(
  "/:id",
  zValidator("json", createShoppingListBodySchema),
  describeRoute({
    tags: ["shopping-list"],
    summary: "Update a shopping list",
    responses: {
      200: {
        description: "Updated",
        content: {
          "application/json": { schema: resolver(shoppingListSchema) },
        },
      },
      404: {
        description: "Shopping list not found",
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const { id } = c.req.param();
    const body = c.req.valid("json");

    try {
      const shoppingList = await c.get("db").shoppingList.update({
        where: { id },
        data: { name: body.name },
        include: { items: { include: { product: true } } },
      });

      return c.json(shoppingList);
    } catch (error) {
      return c.json({ error: "Shopping list not found" }, 404);
    }
  }
);

// Delete a shopping list
const deleteRoute = route().delete(
  "/:id",
  describeRoute({
    tags: ["shopping-list"],
    summary: "Delete a shopping list",
    responses: {
      204: {
        description: "Deleted",
      },
      404: {
        description: "Shopping list not found",
      },
    },
  }),
  async (c) => {
    const { id } = c.req.param();

    try {
      await c.get("db").shoppingList.delete({
        where: { id },
      });

      return c.body(null, 204);
    } catch (error) {
      return c.json({ error: "Shopping list not found" }, 404);
    }
  }
);

// Add item to shopping list
const addItemRoute = route().post(
  "/:id/items",
  zValidator("json", addItemBodySchema),
  describeRoute({
    tags: ["shopping-list"],
    summary: "Add an item to a shopping list",
    responses: {
      201: {
        description: "Item added",
        content: {
          "application/json": { schema: resolver(shoppingListItemSchema) },
        },
      },
      404: {
        description: "Shopping list or product not found",
      },
      409: {
        description: "Product already in shopping list",
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const { id } = c.req.param();
    const body = c.req.valid("json");

    try {
      const item = await c.get("db").shoppingListItem.create({
        data: {
          shoppingListId: id,
          productId: body.productId,
          quantity: body.quantity,
        },
        include: { product: true },
      });

      return c.json(item, 201);
    } catch (error) {
      const errorMessage = String(error);
      if (errorMessage.includes("Unique constraint")) {
        return c.json({ error: "Product already in shopping list" }, 409);
      }
      return c.json({ error: "Shopping list or product not found" }, 404);
    }
  }
);

// Update an item in shopping list
const updateItemRoute = route().patch(
  "/:id/items/:itemId",
  zValidator("json", updateItemBodySchema),
  describeRoute({
    tags: ["shopping-list"],
    summary: "Update an item in a shopping list",
    responses: {
      200: {
        description: "Item updated",
        content: {
          "application/json": { schema: resolver(shoppingListItemSchema) },
        },
      },
      404: {
        description: "Item not found",
      },
      400: {
        description: "Invalid request body",
      },
    },
  }),
  async (c) => {
    const { itemId } = c.req.param();
    const body = c.req.valid("json");

    try {
      const item = await c.get("db").shoppingListItem.update({
        where: { id: itemId },
        data: body,
        include: { product: true },
      });

      return c.json(item);
    } catch (error) {
      return c.json({ error: "Item not found" }, 404);
    }
  }
);

// Remove item from shopping list
const removeItemRoute = route().delete(
  "/:id/items/:itemId",
  describeRoute({
    tags: ["shopping-list"],
    summary: "Remove an item from a shopping list",
    responses: {
      204: {
        description: "Item removed",
      },
      404: {
        description: "Item not found",
      },
    },
  }),
  async (c) => {
    const { itemId } = c.req.param();

    try {
      await c.get("db").shoppingListItem.delete({
        where: { id: itemId },
      });

      return c.body(null, 204);
    } catch (error) {
      return c.json({ error: "Item not found" }, 404);
    }
  }
);

export default route()
  .route("/", getAllRoute)
  .route("/", createRoute)
  .route("/", getByIdRoute)
  .route("/", updateRoute)
  .route("/", deleteRoute)
  .route("/", addItemRoute)
  .route("/", updateItemRoute)
  .route("/", removeItemRoute);
