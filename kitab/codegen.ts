import { CodegenConfig } from "@graphql-codegen/cli"

const GRAPHQL_API_URL = "http://0.0.0.0:4000/graphql"
const config: CodegenConfig = {
  schema: GRAPHQL_API_URL,
  documents: ["./app/**/*.{ts,tsx}"],
  ignoreNoDocuments: true, // for better experience with the watcher
  generates: {
    "./gql/": {
      preset: "client"
    }
  }
}

export default config
