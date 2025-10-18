import {
  PrismaClient,
  type Prisma,
  type AisleType as $AisleType,
} from "@prisma/client";
import path from "node:path";
import fs from "node:fs/promises";

const AisleTypes = [
  "OBSTACLE",
  "FREEZER",
  "DRINKS",
  "PANTRY",
  "SWEETS",
  "CHEESE",
  "MEAT",
  "DAIRY",
  "FRIDGE",
  "FRUIT",
  "VEGETABLES",
  "BAKERY",
  "BAKERY",
  "OTHER",
] as const;

type AisleType = (typeof AisleTypes)[number];

const prisma = new PrismaClient();

const seedDataPath = path.join(import.meta.dirname, "..", "seed");
const productsPath = path.join(seedDataPath, "products.json");
const storesWithAislesPath = path.join(seedDataPath, "store-with-aisles.json");

type Product = {
  productId: string;
  gtin: string;
  name: string;
  description: string;
  price: number;
  pricePerUnit: number;
  unit: string;
  allergens: string[];
  carbonFootprintGram: number;
  organic: boolean;
  aisle: AisleType;
};

type Aisle = {
  type: AisleType;
  x: number;
  y: number;
  width: number;
  height: number;
};

type StoreWithAisles = {
  slug: string;
  name: string;
  aisles: Aisle[];
};

async function main() {
  // Seed products

  const mockProducts: Product[] = JSON.parse(
    await fs.readFile(productsPath, "utf-8")
  ).map((product: any) => ({
    ...product,
    allergens: product.allergens ? product.allergens.split(", ") : [],
  }));
  const mockStoresWithAisles: StoreWithAisles[] = JSON.parse(
    await fs.readFile(storesWithAislesPath, "utf-8")
  );

  // Clear the data
  console.log("Clearing the data...");
  await prisma.product.deleteMany();
  await prisma.store.deleteMany();
  await prisma.aisle.deleteMany();
  await prisma.shoppingList.deleteMany();
  console.log("Creating products...");

  await prisma.product.createMany({
    data: mockProducts.map<Prisma.ProductCreateInput>((product) => ({
      productId: product.productId,
      gtin: product.gtin,
      name: product.name,
      description: product.description,
      price: product.price,
      pricePerUnit: product.pricePerUnit,
      unit: product.unit,
      allergens: product.allergens,
      carbonFootprintGram: product.carbonFootprintGram,
      ...(Math.random() < 0.1 ? { discount: Math.random() * 0.3} : {})
    })),
  });

  const productsCount = await prisma.product.count();
  console.log(`Created ${productsCount} products`);

  console.log("Creating stores...");

  for (const store of mockStoresWithAisles) {
    const createdStore = await prisma.store.create({
      data: {
        slug: store.slug,
        name: store.name,
      },
    });

    console.log(`Created store: ${createdStore.name}`);

    await prisma.aisle.createMany({
      data: store.aisles.map<Prisma.AisleCreateManyInput>((aisle) => ({
        type: aisle.type satisfies $AisleType,
        storeSlug: store.slug,
        gridX: aisle.x,
        gridY: aisle.y,
        width: aisle.width,
        height: aisle.height,
      })),
    });

    const aisles = await prisma.aisle.findMany({
      where: {
        storeSlug: store.slug,
      },
    });

    console.log(
      `Created ${aisles.length} aisles for store: ${createdStore.name}`
    );

    // Evenly  distribute products among the aisles categorized by aisle type
    const aislesByType: Record<
      AisleType,
      { id: string; products: Product[] }[]
    > = {
      // This should be empty
      OBSTACLE: [],
      //
      FREEZER: [],
      DRINKS: [],
      PANTRY: [],
      SWEETS: [],
      CHEESE: [],
      MEAT: [],
      DAIRY: [],
      FRUIT: [],
      OTHER: [],
      VEGETABLES: [],
      BAKERY: [],
      FRIDGE: [],
    };

    for (const aisle of aisles) {
      aislesByType[aisle.type].push({ id: aisle.id, products: [] });
    }

    for (const product of mockProducts) {
      const aisleToAppend = aislesByType[product.aisle]?.sort(
        (a, b) => a.products.length - b.products.length
      )[0];
      if (aisleToAppend == null) {
        console.log(`Aisle ${product.aisle} not found`);
        continue;
      }

      aisleToAppend.products.push(product);
    }

    const entriesToCreate: Prisma.ProductInAisleCreateManyInput[] = [];

    for (const [aisleType, aisles] of Object.entries(aislesByType)) {
      aisles.forEach((aisle) => {
        aisle.products.forEach((product) => {
          entriesToCreate.push({
            aisleId: aisle.id,
            productId: product.productId,
          });
        });
      });
    }

    await prisma.productInAisle.createMany({
      data: entriesToCreate,
    });

    console.log(`Created ${entriesToCreate.length} product in aisle entries`);
  }

  if (mockProducts.length > 0) {
    const products = [...mockProducts];
    products.sort(() => Math.random() - 0.5);

    const randomProducts1 = [];
    const randomProducts2 = [];

    // Add 10 unique products to each shopping list
    for (let i = 0; i < 10; i++) {
      const randomProduct = products.shift();
      if (!randomProduct) {
        continue;
      }
      randomProducts1.push(randomProduct);
      const randomProduct2 = products.shift();
      if (!randomProduct2) {
        continue;
      }
      randomProducts2.push(randomProduct2);
    }

    // Create sample shopping lists
    const shoppingList1 = await prisma.shoppingList.create({
      data: {
        name: "Weekly Groceries",
        items: {
          create: randomProducts1.map((product, index) => ({
            productId: product.productId,
            quantity: index + 1,
            checked: index % 2 === 0,
          })),
        },
      },
    });

    const shoppingList2 = await prisma.shoppingList.create({
      data: {
        name: "Party Shopping",
        items: {
          create: randomProducts2.map((product, index) => ({
            productId: product.productId,
            quantity: (index + 1) * 2,
            checked: false,
          })),
        },
      },
    });

    console.log(`Created shopping list: ${shoppingList1.name}`);
    console.log(`Created shopping list: ${shoppingList2.name}`);
  }

  console.log("Seeding finished.");
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
