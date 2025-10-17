import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const response = await fetch(
    "https://startcode-hackathon2025.azurewebsites.net/api/GetProducts"
  );

  const data = await response.json();
  await prisma.product.createMany({
    data: data,
  });

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
