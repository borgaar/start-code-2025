import { describeRoute, resolver } from "hono-openapi";
import z from "zod";
import { AisleTypeSchema } from "~/generated/zod/schemas/enums/AisleType.schema";
import { route } from "~/lib/route";

const getAisleTypesRoute = route().get(
  "/aisle-types",
  describeRoute({
    tags: ["resources"],
    summary: "Get all available aisle types",
    responses: {
      200: {
        description: "Success",
        content: {
          "application/json": {
            schema: resolver(z.array(z.enum(AisleTypeSchema.def.entries))),
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

export default route().route("/", getAisleTypesRoute);
