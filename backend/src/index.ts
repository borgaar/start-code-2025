import { serve } from "@hono/node-server";
import { Scalar } from "@scalar/hono-api-reference";
import { prisma } from "./db";
import { logger } from "hono/logger";
import { openAPIRouteHandler } from "hono-openapi";
import { AppVariables, route } from "./lib/route";
import productRoute from "./routes/products";
import shoppingListRoute from "./routes/shopping-lists";
import storeRoute from "./routes/store";

export const createApp = async (variables?: AppVariables) => {
  const api = route()
    .basePath("/api")
    .get("/", (c) => {
      return c.text("Healthy!");
    })
    .route("/products", productRoute)
    .route("/shopping-lists", shoppingListRoute)
    .route("/store", storeRoute);

  const app = route()
    .use(logger())
    .use("*", async (c, next) => {
      c.set("db", prisma);
      await next();
    })
    .route("/", api)
    .get(
      "/openapi",
      openAPIRouteHandler(api, {
        documentation: {
          info: {
            title: "Rema 1001 API",
            version: "1.0.0",
            description: "Rema 1001 Hackathon API",
          },
          servers: [
            {
              url: "http://localhost:3000",
              description: "Local Server",
            },
          ],
        },
      })
    )
    .get(
      "/docs",
      Scalar({
        theme: "saturn",
        url: "/openapi",
        sources: [{ url: "/openapi", title: "API" }],
      })
    );

  return app;
};

const app = await createApp();

serve(
  {
    fetch: app.fetch,
    port: 3000,
  },
  (info) => {
    console.log(`📦 Server is running on http://localhost:${info.port}/api`);
  }
);
