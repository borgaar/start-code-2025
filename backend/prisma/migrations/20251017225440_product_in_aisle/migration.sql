/*
  Warnings:

  - The primary key for the `ProductInAisle` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `ProductInAisle` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "public"."ProductInAisle_productId_aisleId_key";

-- AlterTable
ALTER TABLE "ProductInAisle" DROP CONSTRAINT "ProductInAisle_pkey",
DROP COLUMN "id",
ADD CONSTRAINT "ProductInAisle_pkey" PRIMARY KEY ("productId", "aisleId");
