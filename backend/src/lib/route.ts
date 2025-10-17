import type { PrismaClient } from "@prisma/client";
import { Hono } from "hono";

export type AppVariables = {
  db: PrismaClient;
};

export function route() {
  return new Hono<{ Variables: AppVariables }>();
}
