import react from "@vitejs/plugin-react-swc"
import { defineConfig } from "vite"
import tsconfigPaths from "vite-tsconfig-paths"

export default defineConfig(({ mode }) => {
  if (mode === "development") {
    process.stdin.on("close", () => process.exit(0))
    process.stdin.resume()
  }

  return {
    build: {
      outDir: "../priv/static/assets/",
      emptyOutDir: true,
      manifest: true,
      rollupOptions: {
        input: "./src/main.tsx",
        output: {
          entryFileNames: "[name].js",
          chunkFileNames: "[name].js",
          assetFileNames: "[name][extname]"
        }
      }
    },
    server: {
      origin: "http://localhost:5173"
    },
    plugins: [tsconfigPaths(), react()]
  }
})
