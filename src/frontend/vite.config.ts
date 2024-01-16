import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { splitVendorChunkPlugin  } from 'vite'
import cssInjectedByJsPlugin from 'vite-plugin-css-injected-by-js'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react(),splitVendorChunkPlugin(), cssInjectedByJsPlugin()],
    build: {
        outDir: "../backend/static",
        emptyOutDir: true,
        sourcemap: false,
        cssCodeSplit: true,
        rollupOptions: {
            output: {
              manualChunks: {
                vendor: ['react', 'react-router-dom', 'react-dom'],
                fluent: ['@fluentui/react'],
                fluenticon: ['@fluentui/react-icons'],
              }
            },
        },
    },
    server: {
        proxy: {
            "/ask": { target:  "http://localhost:5000/",changeOrigin: true, },
            "/chat":  { target: "http://localhost:5000/",changeOrigin: true,}
        }
    },
});
