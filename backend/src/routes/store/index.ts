import { route } from "~/lib/route";
import {
  getAllStoresRoute,
  createStoreRoute,
  getStoreBySlugRoute,
  updateStoreRoute,
  deleteStoreRoute,
} from "./store.routes";
import {
  getAislesRoute,
  createAisleRoute,
  getAisleRoute,
  updateAisleRoute,
  deleteAisleRoute,
  getAisleTypesRoute,
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
  // Aisle routes
  .route("/", getAislesRoute)
  .route("/", createAisleRoute)
  .route("/", getAisleRoute)
  .route("/", updateAisleRoute)
  .route("/", deleteAisleRoute)
  .route("/", getAisleTypesRoute)
  // Product-Aisle routes
  .route("/", addProductToAisleRoute)
  .route("/", removeProductFromAisleRoute)
  .route("/", getProductsInAisleRoute);
