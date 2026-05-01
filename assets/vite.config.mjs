import path from "node:path";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { phoenixVitePlugin } from "phoenix_vite";
import { defineConfig } from "vite";

export default defineConfig({
  server: {
    port: 5173,
    strictPort: true,
    cors: { origin: "http://localhost:4000" },
  },
  optimizeDeps: {
    // https://vitejs.dev/guide/dep-pre-bundling#monorepos-and-linked-dependencies
    include: ["phoenix", "phoenix_html", "phoenix_live_view"],
  },
  build: {
    manifest: true,
    rollupOptions: {
      input: ["js/app.js", "css/app.css"],
    },
    outDir: "../priv/static",
    emptyOutDir: true,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./js"),
    },
  },
  plugins: [
    tailwindcss(),
    react(),
    phoenixVitePlugin({
      pattern: /\.(ex|heex)$/,
    }),
  ],
});
