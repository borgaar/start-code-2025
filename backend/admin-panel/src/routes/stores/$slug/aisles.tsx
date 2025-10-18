import { createFileRoute, Link, redirect } from '@tanstack/react-router'
import {
  getAislesOptions,
  getStoreOptions,
  useCreateAisle,
  useDeleteAisle,
  useUpdateAisle,
  getAisleTypesOptions,
  useUpdateStore,
  getAislesWithProductsOptions,
  useAddProductToAisle,
  useRemoveProductFromAisle,
  useDistributeProducts,
} from '@/hooks/use-stores'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  ArrowLeft,
  Trash2,
  Move,
  Maximize2,
  Pencil,
  PlusCircleIcon,
  Loader2Icon,
  PlusIcon,
  TrashIcon,
  Shuffle,
} from 'lucide-react'
import { useSuspenseQuery } from '@tanstack/react-query'
import { cn } from '@/lib/utils'
import { useState, useRef, useEffect, Suspense, useMemo } from 'react'
import type { ResponseType } from '@/lib/api'
import {
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { getProductsOptions } from '@/hooks/use-products'

type Tool = 'draw' | 'move' | 'resize' | 'delete' | 'addItems'

type AisleType = ResponseType<'/api/resources/aisle-types', 'get', 200>[number]

interface Aisle {
  id: string
  type: AisleType
  gridX: number
  gridY: number
  width: number
  height: number
}

interface ModifiedAisle {
  id: string
  type: AisleType
  gridX: number
  gridY: number
  width: number
  height: number
}

export const Route = createFileRoute('/stores/$slug/aisles')({
  component: AislesPage,
  loader: async ({ params, context }) => {
    const store = await context.queryClient.ensureQueryData(
      getStoreOptions(params.slug),
    )
    if (!store) {
      throw redirect({
        to: '/stores',
      })
    }

    const aisles = await context.queryClient.ensureQueryData(
      getAislesOptions(params.slug),
    )

    const aisleTypes = await context.queryClient.ensureQueryData(
      getAisleTypesOptions(),
    )

    return { store, aisles: aisles ?? [], aisleTypes: aisleTypes ?? [] }
  },

  pendingComponent: () => (
    <div className="p-8">
      <div className="text-center">Loading aisles...</div>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="p-8">
      <div className="text-center text-red-500">
        Error loading aisles: {error.message}
      </div>
    </div>
  ),
})

function AislesPage() {
  const { slug } = Route.useParams()

  const { data: store } = useSuspenseQuery(getStoreOptions(slug))
  const { data: aisles = [] } = useSuspenseQuery(getAislesOptions(slug))
  const { data: aisleTypes = [] } = useSuspenseQuery(getAisleTypesOptions())
  const createAisle = useCreateAisle()
  const deleteAisle = useDeleteAisle()
  const updateAisle = useUpdateAisle()
  const updateStore = useUpdateStore()
  const distributeProducts = useDistributeProducts()

  // Drawing state
  const [activeTool, setActiveTool] = useState<Tool | null>(null)
  const [selectedAisleType, setSelectedAisleType] =
    useState<AisleType>('PANTRY')
  const [localAisles, setLocalAisles] = useState<Aisle[]>([])

  const [selectedPoint, setSelectedPoint] = useState<
    'entrance' | 'exit' | null
  >(null)
  const [localEntranceCoords, setLocalEntranceCoords] = useState<{
    x: number
    y: number
  }>({
    x: store.entranceX,
    y: store.entranceY,
  })
  const [localExitCoords, setLocalExitCoords] = useState<{
    x: number
    y: number
  }>({
    x: store.exitX,
    y: store.exitY,
  })

  // Drawing interaction state
  const [isDrawing, setIsDrawing] = useState(false)
  const [drawStart, setDrawStart] = useState<{ x: number; y: number } | null>(
    null,
  )
  const [drawEnd, setDrawEnd] = useState<{ x: number; y: number } | null>(null)
  const [selectedAisleId, setSelectedAisleId] = useState<string | null>(null)
  const [dragStart, setDragStart] = useState<{ x: number; y: number } | null>(
    null,
  )
  const [resizeHandle, setResizeHandle] = useState<
    'nw' | 'ne' | 'sw' | 'se' | 'n' | 's' | 'e' | 'w' | null
  >(null)

  const gridRef = useRef<HTMLDivElement>(null)

  // Sync local aisles with server data
  useEffect(() => {
    const sortedAisles = [...aisles]
    sortedAisles.sort((a, b) =>
      a.type === 'OBSTACLE' ? -1 : b.type === 'OBSTACLE' ? 1 : 0,
    )
    setLocalAisles(sortedAisles as Aisle[])
  }, [aisles])

  const getGridCoordinates = (
    clientX: number,
    clientY: number,
  ): { x: number; y: number } | null => {
    if (!gridRef.current) return null
    const rect = gridRef.current.getBoundingClientRect()
    const x = Math.floor((clientX - rect.left) / 10)
    const y = Math.floor((clientY - rect.top) / 10)
    return { x: Math.max(0, Math.min(63, x)), y: Math.max(0, Math.min(63, y)) }
  }

  const getResizeHandle = (
    aisle: Aisle,
    x: number,
    y: number,
  ): 'nw' | 'ne' | 'sw' | 'se' | 'n' | 's' | 'e' | 'w' | null => {
    const threshold = 1
    const isNear = (a: number, b: number) => Math.abs(a - b) <= threshold

    const isTop = isNear(y, aisle.gridY)
    const isBottom = isNear(y, aisle.gridY + aisle.height - 1)
    const isLeft = isNear(x, aisle.gridX)
    const isRight = isNear(x, aisle.gridX + aisle.width - 1)

    if (isTop && isLeft) return 'nw'
    if (isTop && isRight) return 'ne'
    if (isBottom && isLeft) return 'sw'
    if (isBottom && isRight) return 'se'
    if (isTop) return 'n'
    if (isBottom) return 's'
    if (isLeft) return 'w'
    if (isRight) return 'e'
    return null
  }

  const findAisleAtPosition = (x: number, y: number): Aisle | null => {
    const visibleAisles = [...localAisles]
    // De-prioritize obstacles
    visibleAisles.sort((a, b) =>
      a.type === 'OBSTACLE' ? 1 : b.type === 'OBSTACLE' ? -1 : 0,
    )
    return (
      visibleAisles.find(
        (aisle) =>
          x >= aisle.gridX &&
          x < aisle.gridX + aisle.width &&
          y >= aisle.gridY &&
          y < aisle.gridY + aisle.height,
      ) || null
    )
  }

  const handleGridMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!activeTool) return
    e.preventDefault()

    const coords = getGridCoordinates(e.clientX, e.clientY)
    if (!coords) return

    if (activeTool === 'draw') {
      setIsDrawing(true)
      setDrawStart(coords)
      setDrawEnd(coords)
    } else if (activeTool === 'delete') {
      const aisle = findAisleAtPosition(coords.x, coords.y)
      if (aisle) {
        setLocalAisles((prev) => prev.filter((a) => a.id !== aisle.id))
        deleteAisle.mutate({
          slug,
          aisleId: aisle.id,
        })
      }
    } else if (activeTool === 'move') {
      const aisle = findAisleAtPosition(coords.x, coords.y)
      if (
        coords.x === localEntranceCoords.x &&
        coords.y === localEntranceCoords.y
      ) {
        setSelectedPoint('entrance')
        setDragStart(coords)
        return
      }
      if (coords.x === localExitCoords.x && coords.y === localExitCoords.y) {
        setSelectedPoint('exit')
        setDragStart(coords)
        return
      }
      if (aisle) {
        setSelectedAisleId(aisle.id)
        setDragStart(coords)
      }
    } else if (activeTool === 'resize') {
      const aisle = findAisleAtPosition(coords.x, coords.y)
      if (aisle) {
        const handle = getResizeHandle(aisle, coords.x, coords.y)
        if (handle) {
          setSelectedAisleId(aisle.id)
          setResizeHandle(handle)
          setDragStart(coords)
        }
      }
    } else if (activeTool === 'addItems') {
      const aisle = findAisleAtPosition(coords.x, coords.y)

      if (aisle && aisle.type !== 'OBSTACLE') {
        setSelectedAisleId(aisle.id)
      }
    }
  }

  const handleGridMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const coords = getGridCoordinates(e.clientX, e.clientY)
    if (!coords) return

    if (activeTool === 'draw' && isDrawing && drawStart) {
      setDrawEnd(coords)
    } else if (activeTool === 'move' && selectedAisleId && dragStart) {
      const aisle = localAisles.find((a) => a.id === selectedAisleId)
      if (aisle) {
        const deltaX = coords.x - dragStart.x
        const deltaY = coords.y - dragStart.y
        const newX = Math.max(
          0,
          Math.min(64 - aisle.width, aisle.gridX + deltaX),
        )
        const newY = Math.max(
          0,
          Math.min(64 - aisle.height, aisle.gridY + deltaY),
        )

        setLocalAisles((prev) =>
          prev.map((a) =>
            a.id === selectedAisleId ? { ...a, gridX: newX, gridY: newY } : a,
          ),
        )
        setDragStart(coords)
      }
    } else if (
      activeTool === 'resize' &&
      selectedAisleId &&
      resizeHandle &&
      dragStart
    ) {
      const aisle = localAisles.find((a) => a.id === selectedAisleId)
      if (aisle) {
        const deltaX = coords.x - dragStart.x
        const deltaY = coords.y - dragStart.y
        let newX = aisle.gridX
        let newY = aisle.gridY
        let newWidth = aisle.width
        let newHeight = aisle.height

        if (resizeHandle.includes('w')) {
          const maxDelta = aisle.width - 1
          const actualDelta = Math.max(-aisle.gridX, Math.min(maxDelta, deltaX))
          newX = aisle.gridX + actualDelta
          newWidth = aisle.width - actualDelta
        }
        if (resizeHandle.includes('e')) {
          newWidth = Math.max(
            1,
            Math.min(64 - aisle.gridX, aisle.width + deltaX),
          )
        }
        if (resizeHandle.includes('n')) {
          const maxDelta = aisle.height - 1
          const actualDelta = Math.max(-aisle.gridY, Math.min(maxDelta, deltaY))
          newY = aisle.gridY + actualDelta
          newHeight = aisle.height - actualDelta
        }
        if (resizeHandle.includes('s')) {
          newHeight = Math.max(
            1,
            Math.min(64 - aisle.gridY, aisle.height + deltaY),
          )
        }

        setLocalAisles((prev) =>
          prev.map((a) =>
            a.id === selectedAisleId
              ? {
                  ...a,
                  gridX: newX,
                  gridY: newY,
                  width: newWidth,
                  height: newHeight,
                }
              : a,
          ),
        )
        setDragStart(coords)
      }
    } else if (activeTool === 'move' && selectedPoint && dragStart) {
      const newCoords = getGridCoordinates(e.clientX, e.clientY)
      if (newCoords) {
        if (selectedPoint === 'entrance') {
          setLocalEntranceCoords(newCoords)
        }
        if (selectedPoint === 'exit') {
          setLocalExitCoords(newCoords)
        }
      }
    }
  }

  const resetToolState = () => {
    setIsDrawing(false)
    setDrawStart(null)
    setDrawEnd(null)
    setSelectedAisleId(null)
    setDragStart(null)
    setResizeHandle(null)
    setSelectedPoint(null)
  }

  const handleGridMouseUp = () => {
    if (activeTool === 'draw' && isDrawing && drawStart && drawEnd) {
      const x = Math.min(drawStart.x, drawEnd.x)
      const y = Math.min(drawStart.y, drawEnd.y)
      const width = Math.abs(drawEnd.x - drawStart.x) + 1
      const height = Math.abs(drawEnd.y - drawStart.y) + 1

      const newAisle: ModifiedAisle = {
        id: `new-${Date.now()}`,
        type: selectedAisleType,
        gridX: x,
        gridY: y,
        width,
        height,
      }

      setLocalAisles((prev) => [...prev, newAisle as Aisle])

      createAisle.mutate({
        slug,
        body: {
          type: newAisle.type,
          gridX: newAisle.gridX,
          gridY: newAisle.gridY,
          width: newAisle.width,
          height: newAisle.height,
        },
      })
    } else if (activeTool === 'move' && selectedAisleId && dragStart) {
      const aisle = localAisles.find((a) => a.id === selectedAisleId)

      if (aisle) {
        updateAisle.mutate({
          slug,
          aisleId: aisle.id,
          body: {
            gridX: aisle.gridX,
            gridY: aisle.gridY,
            width: aisle.width,
            height: aisle.height,
          },
        })
        setLocalAisles((prev) =>
          prev.map((a) =>
            a.id === aisle.id
              ? { ...a, gridX: aisle.gridX, gridY: aisle.gridY }
              : a,
          ),
        )
      }
    } else if (activeTool === 'resize' && selectedAisleId && resizeHandle) {
      const aisle = localAisles.find((a) => a.id === selectedAisleId)
      if (aisle) {
        updateAisle.mutate({
          slug,
          aisleId: aisle.id,
          body: {
            gridX: aisle.gridX,
            gridY: aisle.gridY,
            width: aisle.width,
            height: aisle.height,
          },
        })
        setLocalAisles((prev) =>
          prev.map((a) =>
            a.id === aisle.id
              ? {
                  ...a,
                  gridX: aisle.gridX,
                  gridY: aisle.gridY,
                  width: aisle.width,
                  height: aisle.height,
                }
              : a,
          ),
        )
      }
    } else if (activeTool === 'move' && selectedPoint) {
      if (selectedPoint === 'entrance') {
        updateStore.mutate({
          slug,
          entranceX: localEntranceCoords.x,
          entranceY: localEntranceCoords.y,
        })
      }
      if (selectedPoint === 'exit') {
        updateStore.mutate({
          slug,
          exitX: localExitCoords.x,
          exitY: localExitCoords.y,
        })
      }
    }
    if (activeTool !== 'addItems') {
      resetToolState()
    }
  }

  const handleChangeClickTool = (tool: Tool) => {
    if (tool === activeTool) {
      setActiveTool(null)
    } else {
      setActiveTool(tool)
    }

    resetToolState()
  }

  const getPreviewRectangle = () => {
    if (!isDrawing || !drawStart || !drawEnd) return null
    return {
      gridX: Math.min(drawStart.x, drawEnd.x),
      gridY: Math.min(drawStart.y, drawEnd.y),
      width: Math.abs(drawEnd.x - drawStart.x) + 1,
      height: Math.abs(drawEnd.y - drawStart.y) + 1,
    }
  }

  const preview = getPreviewRectangle()

  return (
    <div className="p-8">
      <div className="mb-4">
        <Button variant="ghost" asChild>
          <Link to="/stores/$slug" params={{ slug }}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to {store?.name || 'Store'}
          </Link>
        </Button>
      </div>

      {/* Grid Visualization with Drawing Tools */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Store Layout</CardTitle>
        </CardHeader>
        <CardContent>
          {/* Tool Selection */}
          <div className="mb-4 flex items-center gap-4 flex-wrap">
            <div className="flex gap-2">
              <Button
                variant={activeTool === 'addItems' ? 'default' : 'outline'}
                size="sm"
                onClick={() => handleChangeClickTool('addItems')}
              >
                <PlusCircleIcon className="mr-2 h-4 w-4" />
                Manage Products
              </Button>
              <Button
                variant={activeTool === 'draw' ? 'default' : 'outline'}
                size="sm"
                onClick={() => handleChangeClickTool('draw')}
              >
                <Pencil className="mr-2 h-4 w-4" />
                Draw
              </Button>
              <Button
                variant={activeTool === 'move' ? 'default' : 'outline'}
                size="sm"
                onClick={() => handleChangeClickTool('move')}
              >
                <Move className="mr-2 h-4 w-4" />
                Move
              </Button>
              <Button
                variant={activeTool === 'resize' ? 'default' : 'outline'}
                size="sm"
                onClick={() => handleChangeClickTool('resize')}
              >
                <Maximize2 className="mr-2 h-4 w-4" />
                Resize
              </Button>
              <Button
                variant={activeTool === 'delete' ? 'destructive' : 'outline'}
                size="sm"
                onClick={() => handleChangeClickTool('delete')}
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete
              </Button>
            </div>

            <div className="flex gap-2">
              <Button
                variant="secondary"
                size="sm"
                onClick={() => {
                  distributeProducts.mutate(slug)
                }}
                disabled={distributeProducts.isPending}
              >
                {distributeProducts.isPending ? (
                  <Loader2Icon className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Shuffle className="mr-2 h-4 w-4" />
                )}
                Distribute Products
              </Button>
            </div>

            {activeTool === 'draw' && (
              <div className="flex items-center gap-2">
                <span className="text-sm font-medium">Aisle Type:</span>
                <Select
                  value={selectedAisleType}
                  onValueChange={(value) =>
                    setSelectedAisleType(value as AisleType)
                  }
                >
                  <SelectTrigger className="w-[180px]">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {aisleTypes.map((type) => (
                      <SelectItem key={type} value={type}>
                        {type}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}
          </div>

          {/* Grid */}
          <div className="relative p-4 rounded-lg overflow-auto grid grid-cols-2">
            <div
              ref={gridRef}
              className="grid bg-[#434343] cursor-crosshair w-fit"
              style={{
                gridTemplateColumns: 'repeat(64, 10px)',
                gridTemplateRows: 'repeat(64, 10px)',
              }}
              onMouseDown={handleGridMouseDown}
              onMouseMove={handleGridMouseMove}
              onMouseUp={handleGridMouseUp}
              onMouseLeave={handleGridMouseUp}
            >
              {localAisles.map((aisle) => (
                <div
                  key={aisle.id}
                  className={cn(
                    'text-center relative border-2 border-transparent',
                    activeTool === 'move' && 'cursor-move',
                    activeTool === 'resize' && 'cursor-nwse-resize',
                    activeTool === 'delete' &&
                      'cursor-pointer hover:opacity-70',
                    activeTool === 'addItems' &&
                      aisle.type !== 'OBSTACLE' &&
                      'cursor-pointer',
                    activeTool === 'addItems' &&
                      selectedAisleId === aisle.id &&
                      'border-red-500',
                  )}
                  style={{
                    gridColumnStart: aisle.gridX + 1,
                    gridColumnEnd: aisle.gridX + aisle.width + 1,
                    gridRowStart: aisle.gridY + 1,
                    gridRowEnd: aisle.gridY + aisle.height + 1,
                    backgroundColor:
                      aisle.type === 'OBSTACLE' ? '#2c2c2c' : '#6B6B6B',
                  }}
                >
                  {aisle.type !== 'OBSTACLE' && (
                    <span
                      className={cn(
                        'absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-xs pointer-events-none',
                        aisle.height > aisle.width + 1 && 'rotate-90',
                      )}
                    >
                      {aisle.type}
                    </span>
                  )}
                </div>
              ))}

              {/* Entrance */}

              <div
                id="store-entrance"
                className={cn(
                  'bg-green-400',
                  activeTool === 'move' && 'cursor-move',
                  activeTool === 'resize' && 'cursor-not-allowed',
                  activeTool === 'delete' && 'cursor-not-allowed',
                )}
                style={{
                  gridColumnStart: localEntranceCoords.x + 1,
                  gridColumnEnd: localEntranceCoords.x + 1,
                  gridRowStart: localEntranceCoords.y + 1,
                  gridRowEnd: localEntranceCoords.y + 1,
                }}
              >
                Enter
              </div>
              {/* Exit */}
              <div
                id="store-exit"
                className={cn(
                  'bg-red-400',
                  activeTool === 'move' && 'cursor-move',
                  activeTool === 'resize' && 'cursor-not-allowed',
                  activeTool === 'delete' && 'cursor-not-allowed',
                )}
                style={{
                  gridColumnStart: localExitCoords.x + 1,
                  gridColumnEnd: localExitCoords.x + 1,
                  gridRowStart: localExitCoords.y + 1,
                  gridRowEnd: localExitCoords.y + 1,
                }}
              >
                Exit
              </div>

              {/* Draw preview */}
              {preview && (
                <div
                  className="border-2 border-dashed border-blue-400 bg-blue-200/30 pointer-events-none"
                  style={{
                    gridColumnStart: preview.gridX + 1,
                    gridColumnEnd: preview.gridX + preview.width + 1,
                    gridRowStart: preview.gridY + 1,
                    gridRowEnd: preview.gridY + preview.height + 1,
                  }}
                />
              )}
            </div>
            <div>
              {activeTool === 'addItems' && selectedAisleId && (
                <Card className="w-full h-full">
                  <CardHeader>
                    <CardTitle>Add Products to this Aisle</CardTitle>
                  </CardHeader>
                  <CardContent className="h-full">
                    <Suspense
                      fallback={
                        <div className="flex justify-center items-center w-full">
                          <Loader2Icon className="animate-spin" />
                        </div>
                      }
                    >
                      <AddProductsToAisleView
                        aisleId={selectedAisleId}
                        storeSlug={store.slug}
                      />
                    </Suspense>
                  </CardContent>
                </Card>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

function AddProductsToAisleView({
  aisleId,
  storeSlug,
}: {
  aisleId: string
  storeSlug: string
}) {
  const { data: products } = useSuspenseQuery(getProductsOptions())
  const { data: aislesWithProducts } = useSuspenseQuery(
    getAislesWithProductsOptions(storeSlug),
  )

  const addProductToAisle = useAddProductToAisle()
  const removeProductFromAisle = useRemoveProductFromAisle()

  const productsInThisAisle = useMemo(() => {
    return products.filter((product) =>
      aislesWithProducts.some((aisle) =>
        aisle.ProductInAisle.some(
          (productInAisle) =>
            productInAisle.productId === product.productId &&
            productInAisle.aisleId === aisleId,
        ),
      ),
    )
  }, [aisleId, products, aislesWithProducts])

  const availableProducts = useMemo(() => {
    return products.filter(
      (product) =>
        !aislesWithProducts.some((aisles) =>
          aisles.ProductInAisle.some(
            (productInAisle) => productInAisle.productId === product.productId,
          ),
        ),
    )
  }, [products, aislesWithProducts])

  function handleAddProduct(productId: string) {
    addProductToAisle.mutate({
      productId,
      aisleId,
    })
  }

  function handleRemoveProduct(productId: string) {
    removeProductFromAisle.mutate({
      productId,
      aisleId,
    })
  }

  return (
    <div className="h-full contain-size overflow-y-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableCell>Product</TableCell>
            <TableCell>Price</TableCell>
            <TableCell>Added?</TableCell>
          </TableRow>
        </TableHeader>
        <TableBody>
          {availableProducts.map((product) => (
            <TableRow key={product.productId}>
              <TableCell>{product.name}</TableCell>
              <TableCell>
                {product.price} kr / {product.unit}
              </TableCell>
              <TableCell>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleAddProduct(product.productId)}
                >
                  <PlusIcon className="mr-2 h-4 w-4" /> Add
                </Button>
              </TableCell>
            </TableRow>
          ))}
          {productsInThisAisle.map((product) => (
            <TableRow key={product.productId}>
              <TableCell>{product.name}</TableCell>
              <TableCell>
                {product.price} kr / {product.unit}
              </TableCell>
              <TableCell>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => handleRemoveProduct(product.productId)}
                >
                  <TrashIcon className="mr-2 h-4 w-4" /> Remove
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
