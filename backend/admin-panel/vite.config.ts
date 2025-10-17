import { defineConfig } from 'vite'
import viteReact from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

import { TanStackRouterVite } from '@tanstack/router-plugin/vite'
import { resolve } from 'node:path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    TanStackRouterVite({ autoCodeSplitting: true }),
    viteReact(),
    tailwindcss(),
  ],
  base: process.env.NODE_ENV === 'production' ? '/admin/' : '/',
  build: {
    outDir: '../dist/admin-panel',
  },
  server: {
    port: 3030,
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
    },
  },
})
