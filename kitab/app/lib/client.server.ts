import { Client, cacheExchange, fetchExchange } from "@urql/core"
import ky from "ky"

export const createHTTPClient = (baseUrl: string) =>
  ky.create({
    prefixUrl: baseUrl,
    credentials: undefined
  })

export const createGraphQLClient = (baseUrl: string) => (token?: string | null) =>
  new Client({
    url: baseUrl,
    exchanges: [cacheExchange, fetchExchange],
    fetchOptions: {
      headers: {
        authorization: token ? `Bearer ${token}` : ""
      },
      credentials: undefined
    }
  })

export const createClientContext = (baseUrl: string) => {
  const WEB_API_URL = `${baseUrl}/api`
  const GRAPHQL_API_URL = `${baseUrl}/graphql`
  return {
    httpClient: createHTTPClient(WEB_API_URL),
    createGraphQLClient: createGraphQLClient(GRAPHQL_API_URL)
  }
}

export type ClientContext = ReturnType<typeof createClientContext>
