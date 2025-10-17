export interface paths {
    "/api/products": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all products */
        get: operations["getApiProducts"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/products/{id}/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get a product by ID */
        get: operations["getApiProducts:id:id"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/shopping-lists": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all shopping lists */
        get: operations["getApiShopping-lists"];
        put?: never;
        /** Create a new shopping list */
        post: operations["postApiShopping-lists"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/shopping-lists/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get a shopping list by ID */
        get: operations["getApiShopping-lists:id"];
        put?: never;
        post?: never;
        /** Delete a shopping list */
        delete: operations["deleteApiShopping-lists:id"];
        options?: never;
        head?: never;
        /** Update a shopping list */
        patch: operations["patchApiShopping-lists:id"];
        trace?: never;
    };
    "/api/shopping-lists/{id}/items": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Add an item to a shopping list */
        post: operations["postApiShopping-lists:idItems"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/shopping-lists/{id}/items/{itemId}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /** Remove an item from a shopping list */
        delete: operations["deleteApiShopping-lists:idItems:itemId"];
        options?: never;
        head?: never;
        /** Update an item in a shopping list */
        patch: operations["patchApiShopping-lists:idItems:itemId"];
        trace?: never;
    };
    "/api/store": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all stores */
        get: operations["getApiStore"];
        put?: never;
        /** Create a new store */
        post: operations["postApiStore"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/{slug}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get a store by slug/id */
        get: operations["getApiStore:slug"];
        /** Update a store */
        put: operations["putApiStore:slug"];
        post?: never;
        /** Delete a store */
        delete: operations["deleteApiStore:slug"];
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/{slug}/aisle": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all aisles for a store */
        get: operations["getApiStore:slugAisle"];
        put?: never;
        /** Create a new aisle for a store */
        post: operations["postApiStore:slugAisle"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/{slug}/aisle/{aisleId}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get a specific aisle */
        get: operations["getApiStore:slugAisle:aisleId"];
        /** Update an aisle */
        put: operations["putApiStore:slugAisle:aisleId"];
        post?: never;
        /** Delete an aisle */
        delete: operations["deleteApiStore:slugAisle:aisleId"];
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/aisle-types": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all available aisle types */
        get: operations["getApiStoreAisle-types"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/product-in-aisle": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Add a product to an aisle */
        post: operations["postApiStoreProduct-in-aisle"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/product-in-aisle/{productId}/{aisleId}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        post?: never;
        /** Remove a product from an aisle */
        delete: operations["deleteApiStoreProduct-in-aisle:productId:aisleId"];
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/store/{slug}/aisle/{aisleId}/products": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get all products in an aisle */
        get: operations["getApiStore:slugAisle:aisleIdProducts"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
}
export type webhooks = Record<string, never>;
export interface components {
    schemas: never;
    responses: never;
    parameters: never;
    requestBodies: never;
    headers: never;
    pathItems: never;
}
export type $defs = Record<string, never>;
export interface operations {
    getApiProducts: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
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
                        updatedAt: string;
                        createdAt: string;
                    }[];
                };
            };
        };
    };
    "getApiProducts:id:id": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Product found */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
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
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Product not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiShopping-lists": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    }[];
                };
            };
        };
    };
    "postApiShopping-lists": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Created */
            201: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiShopping-lists:id": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Shopping list found */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Shopping list not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "deleteApiShopping-lists:id": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Deleted */
            204: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Shopping list not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "patchApiShopping-lists:id": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Shopping list not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "postApiShopping-lists:idItems": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Item added */
            201: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        shoppingListId: string;
                        productId: string;
                        /** @default 1 */
                        quantity: number;
                        checked: boolean;
                        product: {
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
                            updatedAt: string;
                            createdAt: string;
                        };
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Shopping list or product not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Product already in shopping list */
            409: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "deleteApiShopping-lists:idItems:itemId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
                itemId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Item removed */
            204: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Item not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "patchApiShopping-lists:idItems:itemId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
                itemId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Item updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        shoppingListId: string;
                        productId: string;
                        /** @default 1 */
                        quantity: number;
                        checked: boolean;
                        product: {
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
                            updatedAt: string;
                            createdAt: string;
                        };
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Item not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    getApiStore: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        slug: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    }[];
                };
            };
        };
    };
    postApiStore: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Created */
            201: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        slug: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Store with this ID already exists */
            409: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiStore:slug": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Store found */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        slug: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Store not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "putApiStore:slug": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        slug: string;
                        name: string;
                        updatedAt: string;
                        createdAt: string;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Store not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "deleteApiStore:slug": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Deleted */
            204: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Store not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiStore:slugAisle": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        storeSlug: string;
                        /** @enum {string} */
                        type: "OBSTACLE" | "FREEZER" | "DRINKS" | "PANTRY" | "SWEETS" | "CHEESE" | "MEAT" | "DAIRY" | "FRIDGE" | "FRUIT" | "VEGETABLES" | "BAKERY" | "OTHER";
                        gridX: number;
                        gridY: number;
                        width: number;
                        height: number;
                    }[];
                };
            };
            /** @description Store not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "postApiStore:slugAisle": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Created */
            201: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        storeSlug: string;
                        /** @enum {string} */
                        type: "OBSTACLE" | "FREEZER" | "DRINKS" | "PANTRY" | "SWEETS" | "CHEESE" | "MEAT" | "DAIRY" | "FRIDGE" | "FRUIT" | "VEGETABLES" | "BAKERY" | "OTHER";
                        gridX: number;
                        gridY: number;
                        width: number;
                        height: number;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Store not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Aisle with this ID already exists */
            409: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiStore:slugAisle:aisleId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
                aisleId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Aisle found */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        storeSlug: string;
                        /** @enum {string} */
                        type: "OBSTACLE" | "FREEZER" | "DRINKS" | "PANTRY" | "SWEETS" | "CHEESE" | "MEAT" | "DAIRY" | "FRIDGE" | "FRUIT" | "VEGETABLES" | "BAKERY" | "OTHER";
                        gridX: number;
                        gridY: number;
                        width: number;
                        height: number;
                    };
                };
            };
            /** @description Aisle not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "putApiStore:slugAisle:aisleId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
                aisleId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        storeSlug: string;
                        /** @enum {string} */
                        type: "OBSTACLE" | "FREEZER" | "DRINKS" | "PANTRY" | "SWEETS" | "CHEESE" | "MEAT" | "DAIRY" | "FRIDGE" | "FRUIT" | "VEGETABLES" | "BAKERY" | "OTHER";
                        gridX: number;
                        gridY: number;
                        width: number;
                        height: number;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Aisle not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "deleteApiStore:slugAisle:aisleId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
                aisleId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Deleted */
            204: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Aisle not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiStoreAisle-types": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": string[];
                };
            };
        };
    };
    "postApiStoreProduct-in-aisle": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Product added to aisle */
            201: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        productId: string;
                        aisleId: string;
                    };
                };
            };
            /** @description Invalid request body */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Product or aisle not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Product already in this aisle */
            409: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "deleteApiStoreProduct-in-aisle:productId:aisleId": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                productId: string;
                aisleId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Product removed from aisle */
            204: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Product-aisle association not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    "getApiStore:slugAisle:aisleIdProducts": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                slug: string;
                aisleId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Success */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content: {
                    "application/json": {
                        id: string;
                        productId: string;
                        aisleId: string;
                        product: {
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
                            updatedAt: string;
                            createdAt: string;
                        };
                    }[];
                };
            };
            /** @description Aisle not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
}
