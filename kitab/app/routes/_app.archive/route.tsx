import { json, type LoaderFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { graphql } from "gql"
import { Center } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { ThreadList } from "~/routes/_app.archive/thread-list"

export const meta: MetaFunction = () => {
  return [{ title: "Archive - LITTLE RED BOOK" }]
}

const ListThreadsQuery = graphql(`
  query ListThreads($first: Int, $after: String) {
    threads(first: $first, after: $after) {
      edges {
        node {
          group {
            gid
            id
            name
          }
          id
          messages {
            content {
              ... on AtMessageContent {
                __typename
                name
                qid
              }
              ... on ImageMessageContent {
                __typename
                url
              }
              ... on TextMessageContent {
                __typename
                text
              }
            }
            id
            sender {
              id
              name
              qid
            }
            sentAt
          }
          owner {
            id
            name
            qid
          }
          postedAt
        }
      }
      pageInfo {
        hasNextPage
        hasPreviousPage
        endCursor
      }
    }
  }
`)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const { data } = await client.query(ListThreadsQuery, { first: 8 }).toPromise()
  invariant(data)
  return json({ threads: data.threads.edges })
}

export default function Archive() {
  return (
    <Center mx="4" py="4" lg={{ py: "8" }}>
      <ThreadList />
    </Center>
  )
}
