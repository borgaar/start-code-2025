import data from "./seed/store-with-aisles.json";
import chalk from "chalk";

interface Aisle {
  type: string;
  x: number;
  y: number;
  width: number;
  height: number;
}

interface Store {
  slug: string;
  name: string;
  entrance: number[];
  exit: number[];
  aisles: Aisle[];
}

function getColorForAisleType(type: string): (text: string) => string {
  switch (type) {
    case "FRIDGE":
      return chalk.cyan;
    case "FREEZER":
      return chalk.blue;
    case "FRUIT":
      return chalk.hex("#00FF00");
    case "VEGETABLES":
      return chalk.green;
    case "DAIRY":
      return chalk.white;
    case "CHEESE":
      return chalk.yellowBright;
    case "MEAT":
      return chalk.red;
    case "FROZEN":
      return chalk.blueBright;
    case "PANTRY":
      return chalk.magenta;
    case "OBSTACLE":
      return chalk.gray;
    case "OTHER":
      return chalk.white;
    case "DRINKS":
      return chalk.cyanBright;
    case "SWEETS":
      return chalk.hex("#FFC0CB");
    default:
      return chalk.white;
  }
}

function printStoreLayout() {
  // Read the JSON file
  const stores: Store[] = data;

  // Process each store
  stores.forEach((store) => {
    // Create a 64x64 grid filled with '.'
    const grid: string[][] = Array(64)
      .fill(null)
      .map(() => Array(64).fill(".."));

    // Fill in the aisles with colored characters based on type
    store.aisles.forEach((aisle) => {
      const colorFn = getColorForAisleType(aisle.type);
      for (let y = aisle.y; y < aisle.y + aisle.height; y++) {
        for (let x = aisle.x; x < aisle.x + aisle.width; x++) {
          if (y >= 0 && y < 64 && x >= 0 && x < 64) {
            grid[y]![x] = colorFn("##");
          }
        }
      }
    });

    grid[store.entrance[1]!]![store.entrance[0]!] = chalk.green("EE");
    grid[store.exit[1]!]![store.exit[0]!] = chalk.red("XX");

    // Print the grid
    for (let y = 0; y < 64; y++) {
      console.log(grid[y]?.join("") || "");
    }
  });
}

printStoreLayout();
