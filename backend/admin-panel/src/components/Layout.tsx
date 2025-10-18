import { Link, useRouterState } from '@tanstack/react-router'
import { Button } from '@/components/ui/button'
import { Package, ShoppingCart, Store, Home } from 'lucide-react'

export function Layout({ children }: { children: React.ReactNode }) {
  const router = useRouterState()
  const currentPath = router.location.pathname

  const isActive = (path: string) => {
    if (path === '/') {
      return currentPath === '/'
    }
    return currentPath.startsWith(path)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white border-b">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            <Link to="/" className="font-bold text-xl">
              Admin Panel
            </Link>
            <div className="flex gap-2">
              <Button
                variant={
                  isActive('/') && currentPath === '/' ? 'default' : 'ghost'
                }
                asChild
              >
                <Link to="/">
                  <Home className="mr-2 h-4 w-4" />
                  Home
                </Link>
              </Button>
              <Button
                variant={isActive('/products') ? 'default' : 'ghost'}
                asChild
              >
                <Link to="/products">
                  <Package className="mr-2 h-4 w-4" />
                  Products
                </Link>
              </Button>
              <Button
                variant={isActive('/shopping-lists') ? 'default' : 'ghost'}
                asChild
              >
                <Link to="/shopping-lists">
                  <ShoppingCart className="mr-2 h-4 w-4" />
                  Shopping Lists
                </Link>
              </Button>
              <Button
                variant={isActive('/stores') ? 'default' : 'ghost'}
                asChild
              >
                <Link to="/stores">
                  <Store className="mr-2 h-4 w-4" />
                  Stores
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </nav>
      <main>{children}</main>
    </div>
  )
}
