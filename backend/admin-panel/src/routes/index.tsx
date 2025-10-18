import { createFileRoute } from '@tanstack/react-router'
import { Card, CardHeader } from '@/components/ui/card'

export const Route = createFileRoute('/')({
  component: App,
})

function App() {
  return (
    <div className="p-20">
      <Card>
        <CardHeader>Admin Panel</CardHeader>
      </Card>
    </div>
  )
}
