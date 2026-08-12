import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: '/panel/',
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:5137',
      '/clinical': 'http://localhost:5276'
    }
  },
  build: {
    outDir: 'dist'
  }
});