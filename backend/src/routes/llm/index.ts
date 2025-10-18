import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { zValidator } from "@hono/zod-validator";
import z from "zod";
import Anthropic from "@anthropic-ai/sdk";

const GenerateShoppingListRequestSchema = z.object({
  query: z.string().min(1, "Query is required"),
});

const ShoppingListItemResponseSchema = z.object({
  productId: z.string(),
  name: z.string(),
  quantity: z.number(),
  unit: z.string(),
});

const ShoppingListOptionSchema = z.object({
  title: z.string(),
  items: z.array(ShoppingListItemResponseSchema),
});

const GenerateShoppingListResponseSchema = z.object({
  lists: z.array(ShoppingListOptionSchema),
});

const generateShoppingListRequestBodyOpenAPI = await resolver(
  GenerateShoppingListRequestSchema
).toOpenAPISchema();

const generateShoppingListRoute = route().post(
  "/shopping-list",
  zValidator("json", GenerateShoppingListRequestSchema),
  describeRoute({
    tags: ["llm"],
    summary:
      "Generate multiple shopping list options based on a recipe query (e.g., 3 different cake recipes)",
    requestBody: {
      content: {
        "application/json": {
          schema: generateShoppingListRequestBodyOpenAPI.schema,
        },
      },
    },
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(GenerateShoppingListResponseSchema),
          },
        },
      },
      400: {
        description: "Invalid request body",
      },
      500: {
        description: "LLM API error",
      },
    },
  }),
  async (c) => {
    const { query } = c.req.valid("json");
    const apiKey = process.env.ANTHROPIC_API_KEY;

    if (!apiKey) {
      return c.json({ error: "ANTHROPIC_API_KEY not configured" }, 500);
    }

    try {
      // Fetch all products from database
      const products = await c.get("db").product.findMany({
        select: {
          productId: true,
          name: true,
          description: true,
          unit: true,
          price: true,
          organic: true,
          allergens: true,
        },
      });

      // Build the available products list for the prompt
      const productsContext = products
        .map(
          (p) =>
            `- ID: ${p.productId}, Name: ${p.name}, Description: ${
              p.description
            }, Unit: ${p.unit}, Price: ${p.price}, Organic: ${
              p.organic
            }, Allergens: ${p.allergens.join(", ")}`
        )
        .join("\n");

      const anthropic = new Anthropic({ apiKey });

      const message = await anthropic.messages.create({
        model: "claude-sonnet-4-5",
        max_tokens: 4096,
        tools: [
          {
            name: "create_shopping_lists",
            description:
              "Creates multiple shopping list options with recommended products and quantities based on the recipe query",
            input_schema: {
              type: "object",
              properties: {
                lists: {
                  type: "array",
                  description:
                    "Array of shopping list options (e.g., different cake recipes)",
                  items: {
                    type: "object",
                    properties: {
                      title: {
                        type: "string",
                        description:
                          "The title/name of this shopping list option (e.g., 'Chocolate Cake', 'Vanilla Cake')",
                      },
                      items: {
                        type: "array",
                        description: "List of shopping list items for this option",
                        items: {
                          type: "object",
                          properties: {
                            productId: {
                              type: "string",
                              description:
                                "The product ID from the available products list",
                            },
                            quantity: {
                              type: "number",
                              description:
                                "Quantity needed in terms of the product's unit",
                            },
                          },
                          required: ["productId", "quantity"],
                        },
                      },
                    },
                    required: ["title", "items"],
                  },
                },
              },
              required: ["lists"],
            },
          },
        ],
        messages: [
          {
            role: "user",
            content: `You are a helpful shopping assistant. Based on the recipe query below, recommend shopping lists with items from our available products.

Recipe Query: "${query}"

Available Products:
${productsContext}

Please analyze the query and suggest multiple recipe/meal options (typically 2-4 options) that match the query. For each option, provide:
1. A descriptive title (e.g., "Chocolate Cake", "Vanilla Sponge Cake")
2. The list of products needed with appropriate quantities

Use the create_shopping_lists tool to return your recommendations. Each list should be a different variation or option that fits the query.`,
          },
        ],
      });

      // Extract tool use from response
      const toolUse = message.content.find(
        (block) => block.type === "tool_use"
      );

      if (!toolUse || toolUse.type !== "tool_use") {
        return c.json(
          { error: "LLM did not return expected tool response" },
          500
        );
      }

      const recommendedLists = (
        toolUse.input as {
          lists: Array<{
            title: string;
            items: Array<{ productId: string; quantity: number }>;
          }>;
        }
      ).lists;

      // Add unit and name information from database for each list
      const listsWithProductDetails = recommendedLists.map((list) => ({
        title: list.title,
        items: list.items.map((item) => {
          const product = products.find((p) => p.productId === item.productId);
          return {
            productId: item.productId,
            name: product?.name || "unknown",
            quantity: item.quantity,
            unit: product?.unit || "unknown",
          };
        }),
      }));

      return c.json({ lists: listsWithProductDetails });
    } catch (error) {
      console.error("LLM API error:", error);
      return c.json({ error: "Failed to generate shopping list" }, 500);
    }
  }
);

export default route().route("/", generateShoppingListRoute);
