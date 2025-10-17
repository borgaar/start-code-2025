import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";

const productSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  price: z.number(),
  stock: z.number(),
  sku: z.string(),
  category: z.string(),
});

const getAllRoute = route().get(
  "/",
  describeRoute({
    tags: ["product"],
    summary: "Get all products",
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": { schema: resolver(productSchema) },
        },
      },
    },
  }),
  async (c) => {
    const products = await c.get("db").product.findMany();
    return c.json(products);
  }
);

const getByIdRoute = route().get(
  "/:id",
  describeRoute({
    tags: ["product"],
    summary: "Get a product by ID",
    responses: {
      200: {
        description: "Product found",
        content: {
          "application/json": { schema: resolver(productSchema) },
        },
      },
    },
  }),
  async (c) => {
    const { id } = c.req.param();
    const product = await c.get("db").product.findUnique({ where: { id } });
    return c.json(product);
  }
);

export default route()
  //
  .route("/", getAllRoute)
  .route("/:id", getByIdRoute);
