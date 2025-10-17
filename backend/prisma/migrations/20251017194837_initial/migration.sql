-- CreateEnum
CREATE TYPE "AisleType" AS ENUM ('OBSTACLE', 'FREEZER', 'DRINKS', 'PANTRY', 'SWEETS', 'CHEESE', 'MEAT', 'DAIRY', 'FRIDGE', 'FRUIT', 'VEGETABLES', 'BAKERY', 'OTHER');

-- CreateTable
CREATE TABLE "Product" (
    "productId" TEXT NOT NULL,
    "gtin" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "pricePerUnit" DOUBLE PRECISION NOT NULL,
    "unit" TEXT NOT NULL,
    "allergens" TEXT[],
    "carbonFootprintGram" DOUBLE PRECISION NOT NULL,
    "organic" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Product_pkey" PRIMARY KEY ("productId")
);

-- CreateTable
CREATE TABLE "ShoppingList" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ShoppingList_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShoppingListItem" (
    "id" TEXT NOT NULL,
    "shoppingListId" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "checked" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "ShoppingListItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Store" (
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Store_pkey" PRIMARY KEY ("slug")
);

-- CreateTable
CREATE TABLE "Aisle" (
    "id" TEXT NOT NULL,
    "storeSlug" TEXT NOT NULL,
    "type" "AisleType" NOT NULL,
    "gridX" INTEGER NOT NULL,
    "gridY" INTEGER NOT NULL,
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,

    CONSTRAINT "Aisle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductInAisle" (
    "id" TEXT NOT NULL,
    "productId" TEXT NOT NULL,
    "aisleId" TEXT NOT NULL,

    CONSTRAINT "ProductInAisle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Product_gtin_key" ON "Product"("gtin");

-- CreateIndex
CREATE INDEX "Product_productId_idx" ON "Product"("productId");

-- CreateIndex
CREATE INDEX "Product_gtin_idx" ON "Product"("gtin");

-- CreateIndex
CREATE INDEX "Product_organic_idx" ON "Product"("organic");

-- CreateIndex
CREATE INDEX "Product_unit_idx" ON "Product"("unit");

-- CreateIndex
CREATE INDEX "ShoppingList_createdAt_idx" ON "ShoppingList"("createdAt");

-- CreateIndex
CREATE INDEX "ShoppingListItem_shoppingListId_idx" ON "ShoppingListItem"("shoppingListId");

-- CreateIndex
CREATE INDEX "ShoppingListItem_productId_idx" ON "ShoppingListItem"("productId");

-- CreateIndex
CREATE UNIQUE INDEX "ShoppingListItem_shoppingListId_productId_key" ON "ShoppingListItem"("shoppingListId", "productId");

-- CreateIndex
CREATE INDEX "Store_name_idx" ON "Store"("name");

-- CreateIndex
CREATE INDEX "Aisle_gridX_idx" ON "Aisle"("gridX");

-- CreateIndex
CREATE INDEX "Aisle_gridY_idx" ON "Aisle"("gridY");

-- CreateIndex
CREATE INDEX "Aisle_width_idx" ON "Aisle"("width");

-- CreateIndex
CREATE INDEX "Aisle_height_idx" ON "Aisle"("height");

-- CreateIndex
CREATE INDEX "Aisle_storeSlug_idx" ON "Aisle"("storeSlug");

-- CreateIndex
CREATE INDEX "Aisle_type_idx" ON "Aisle"("type");

-- CreateIndex
CREATE INDEX "ProductInAisle_productId_idx" ON "ProductInAisle"("productId");

-- CreateIndex
CREATE INDEX "ProductInAisle_aisleId_idx" ON "ProductInAisle"("aisleId");

-- CreateIndex
CREATE UNIQUE INDEX "ProductInAisle_productId_aisleId_key" ON "ProductInAisle"("productId", "aisleId");

-- AddForeignKey
ALTER TABLE "ShoppingListItem" ADD CONSTRAINT "ShoppingListItem_shoppingListId_fkey" FOREIGN KEY ("shoppingListId") REFERENCES "ShoppingList"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShoppingListItem" ADD CONSTRAINT "ShoppingListItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("productId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Aisle" ADD CONSTRAINT "Aisle_storeSlug_fkey" FOREIGN KEY ("storeSlug") REFERENCES "Store"("slug") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductInAisle" ADD CONSTRAINT "ProductInAisle_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("productId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProductInAisle" ADD CONSTRAINT "ProductInAisle_aisleId_fkey" FOREIGN KEY ("aisleId") REFERENCES "Aisle"("id") ON DELETE CASCADE ON UPDATE CASCADE;
