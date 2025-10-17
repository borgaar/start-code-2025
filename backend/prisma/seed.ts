import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("Start seeding...");

  // Create some sample products
  const products = [
    {
      productId: "1001",
      gtin: "7091234000013",
      name: "Grovt brød 750 g",
      description: "Nybakt, grovt brød med høy fiber.",
      price: 44.18,
      pricePerUnit: 58.91,
      unit: "kg",
      allergens: "hvete, gluten, melk",
      carbonFootprintGram: 325,
      organic: false,
    },
    {
      productId: "1002",
      gtin: "7091234000020",
      name: "Økologisk melk 1L",
      description: "Fersk, økologisk helmelk fra norske gårder.",
      price: 24.9,
      pricePerUnit: 24.9,
      unit: "liter",
      allergens: "melk",
      carbonFootprintGram: 890,
      organic: true,
    },
    {
      productId: "1003",
      gtin: "7091234000037",
      name: "Epler Granny Smith 1kg",
      description: "Sprø og sure epler, perfekte for baking og snacking.",
      price: 39.9,
      pricePerUnit: 39.9,
      unit: "kg",
      allergens: null,
      carbonFootprintGram: 150,
      organic: false,
    },
    {
      productId: "1004",
      gtin: "7091234000044",
      name: "Pasta Fullkorn 500g",
      description: "Italiensk fullkornspasta med høy fiberinnhold.",
      price: 32.5,
      pricePerUnit: 65.0,
      unit: "kg",
      allergens: "hvete, gluten",
      carbonFootprintGram: 420,
      organic: true,
    },
  ];

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
