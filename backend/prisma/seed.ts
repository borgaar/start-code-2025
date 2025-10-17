import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  // Seed products
  const existingProducts = await prisma.product.count();

  if (existingProducts === 0) {
    const response = await fetch(
      "https://startcode-hackathon2025.azurewebsites.net/api/GetProducts"
    );

    const data = await response.json();
    await prisma.product.createMany({
      data: data,
    });

    console.log("Products seeded.");
  } else {
    console.log(
      `Products already seeded (${existingProducts} products found).`
    );
  }

  // Get some products for shopping list
  const products = await prisma.product.findMany({
    take: 10,
  });

  if (products.length > 0) {
    // Delete existing sample shopping lists if they exist
    await prisma.shoppingList.deleteMany({
      where: {
        name: {
          in: ["Weekly Groceries", "Party Shopping"],
        },
      },
    });

    // Create sample shopping lists
    const shoppingList1 = await prisma.shoppingList.create({
      data: {
        name: "Weekly Groceries",
        items: {
          create: products.slice(0, 5).map((product, index) => ({
            productId: product.id,
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
          create: products.slice(5, 10).map((product, index) => ({
            productId: product.id,
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
