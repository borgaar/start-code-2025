import { route } from "~/lib/route";
import {
  getAllStoresRoute,
  createStoreRoute,
  getStoreBySlugRoute,
  updateStoreRoute,
  deleteStoreRoute,
  distributeProductsRoute,
} from "./store.routes";
import {
  getAislesRoute,
  createAisleRoute,
  getAisleRoute,
  updateAisleRoute,
  deleteAisleRoute,
  getAislesWithProductsRoute,
} from "./aisle.routes";
import {
  addProductToAisleRoute,
  removeProductFromAisleRoute,
  getProductsInAisleRoute,
} from "./product-aisle.routes";

export default route()
  // Store routes
  .route("/", getAllStoresRoute)
  .route("/", createStoreRoute)
  .route("/", getStoreBySlugRoute)
  .route("/", updateStoreRoute)
  .route("/", deleteStoreRoute)
  .route("/", distributeProductsRoute)
  // Aisle routes
  .route("/", getAislesRoute)
  .route("/", createAisleRoute)
  .route("/", getAisleRoute)
  .route("/", updateAisleRoute)
  .route("/", deleteAisleRoute)
  .route("/", getAislesWithProductsRoute)
  // Product-Aisle routes
  .route("/", addProductToAisleRoute)
  .route("/", removeProductFromAisleRoute)
  .route("/", getProductsInAisleRoute);
