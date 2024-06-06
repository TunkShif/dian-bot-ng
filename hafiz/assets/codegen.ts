import type { CodegenConfig } from "@graphql-codegen/cli"

const GRAPHQL_API_URL = process.env.HAFIZ_API_URL || "http://localhost:4000/graphql"

export default {
  schema: GRAPHQL_API_URL,
  documents: ["src/**/*.{ts,tsx}"],
  ignoreNoDocuments: true, // for better experience with the watcher
  generates: {
    "./gql/": {
      preset: "client"
    }
  },
  watch: true
} satisfies CodegenConfig
