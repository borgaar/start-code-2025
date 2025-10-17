import { z } from "zod";

// Aisle type enum
export const aisleTypeSchema = z.enum([
  "FRIDGE",
  "FREEZER",
  "FRUIT",
  "VEGETABLES",
  "DAIRY",
  "CHEESE",
  "MEAT",
  "FROZEN",
  "PANTRY",
  "OTHER",
  "OBSTACLE",
]);

// Response schemas
export const aisleSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: aisleTypeSchema,
  gridX: z.number(),
  gridY: z.number(),
  width: z.number(),
  height: z.number(),
  storeId: z.string(),
});

export const storeSchema = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const storeWithAislesSchema = z.object({
  id: z.string(),
  name: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
  aisles: z.array(aisleSchema),
});

export const productSchema = z.object({
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
});

export const productInAisleSchema = z.object({
  id: z.string(),
  productId: z.string(),
  aisleId: z.string(),
});

export const productInAisleWithProductSchema = z.object({
  id: z.string(),
  productId: z.string(),
  aisleId: z.string(),
  product: productSchema,
});

// Request body schemas
export const createStoreBodySchema = z.object({
  id: z.string().min(1, "ID is required"),
  name: z.string().min(1, "Name is required"),
});

export const updateStoreBodySchema = z.object({
  name: z.string().min(1, "Name is required"),
});

export const createAisleBodySchema = z.object({
  id: z.string().min(1, "ID is required"),
  name: z.string().min(1, "Name is required"),
  type: aisleTypeSchema.default("OTHER"),
  gridX: z.number().int(),
  gridY: z.number().int(),
  width: z.number().int().positive(),
  height: z.number().int().positive(),
});

export const updateAisleBodySchema = z.object({
  name: z.string().min(1, "Name is required").optional(),
  type: aisleTypeSchema.optional(),
  gridX: z.number().int().optional(),
  gridY: z.number().int().optional(),
  width: z.number().int().positive().optional(),
  height: z.number().int().positive().optional(),
});

export const addProductToAisleBodySchema = z.object({
  productId: z.string().min(1, "Product ID is required"),
  aisleId: z.string().min(1, "Aisle ID is required"),
});
