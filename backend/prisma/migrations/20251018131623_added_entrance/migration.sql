/*
  Warnings:

  - Added the required column `entranceX` to the `Store` table without a default value. This is not possible if the table is not empty.
  - Added the required column `entranceY` to the `Store` table without a default value. This is not possible if the table is not empty.
  - Added the required column `exitX` to the `Store` table without a default value. This is not possible if the table is not empty.
  - Added the required column `exitY` to the `Store` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable

ALTER TABLE "Store" ADD COLUMN     "entranceX" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "entranceY" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "exitX" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "exitY" INTEGER NOT NULL DEFAULT 0;
