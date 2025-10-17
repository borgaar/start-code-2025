import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("Start seeding...");

  // Create some sample products
  const products = [
    {
      name: "Wireless Headphones",
      description: "High-quality wireless headphones with noise cancellation",
      price: 299.99,
      stock: 50,
      sku: "WH-001",
      category: "Electronics",
      imageUrl: "https://example.com/headphones.jpg",
      isActive: true,
    },
    {
      name: "Smart Watch",
      description: "Fitness tracker with heart rate monitor",
      price: 199.99,
      stock: 30,
      sku: "SW-002",
      category: "Electronics",
      imageUrl: "https://example.com/smartwatch.jpg",
      isActive: true,
    },
    {
      name: "Running Shoes",
      description: "Comfortable running shoes for all terrains",
      price: 89.99,
      stock: 100,
      sku: "RS-003",
      category: "Sports",
      imageUrl: "https://example.com/shoes.jpg",
      isActive: true,
    },
    {
      name: "Coffee Maker",
      description: "Automatic coffee maker with timer",
      price: 149.99,
      stock: 25,
      sku: "CM-004",
      category: "Home & Kitchen",
      imageUrl: "https://example.com/coffee.jpg",
      isActive: true,
    },
  ];

  for (const product of products) {
    const created = await prisma.product.upsert({
      where: { sku: product.sku },
      update: {},
      create: product,
    });
    console.log(`Created product: ${created.name} (${created.sku})`);
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
