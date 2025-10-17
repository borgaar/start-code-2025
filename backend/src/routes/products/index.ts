import { describeRoute, resolver } from "hono-openapi";
import { route } from "~/lib/route";
import { z } from "zod";
import { ProductSchema } from "~/generated/zod/schemas/models";

const getAllRoute = route().get(
  "/",
  describeRoute({
    tags: ["product"],
    summary: "Get all products",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": { schema: resolver(z.array(ProductSchema)) },
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
          "application/json": { schema: resolver(ProductSchema) },
        },
      },
      404: {
        description: "Product not found",
      },
    },
  }),
  async (c) => {
    const { id } = c.req.param();
    const product = await c
      .get("db")
      .product.findUnique({ where: { productId: id } });
    if (!product) {
      return c.json({ error: "Product not found" }, 404);
    }
    return c.json(product);
  }
);

export default route()
  //
  .route("/", getAllRoute)
  .route("/:id", getByIdRoute);
