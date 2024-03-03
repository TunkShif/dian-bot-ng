import { json, type LoaderFunctionArgs } from "@remix-run/cloudflare"
import { useLoaderData } from "@remix-run/react"
import { graphql } from "gql"
import type { Thread } from "gql/graphql"
import { Box } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { ThreadItem } from "~/routes/_app.archive/thread-item"

const ThreadQuery = graphql(`
  query Thread($id: ID!) {
    node(id: $id) {
      __typename
      id
      ... on Thread {
        group {
          id
          gid
          name
        }
        id
        messages {
          id
          sender {
            id
            name
            qid
          }
          sentAt
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
        }
        owner {
          id
          name
          qid
        }
        postedAt
      }
    }
  }
`)

export const loader = async ({ request, params, context }: LoaderFunctionArgs) => {
  const id = params.id
  invariant(id)

  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const { data } = await client.query(ThreadQuery, { id }).toPromise()
  invariant(data?.node?.__typename === "Thread")

  return json({ thread: data.node })
}

export default function ArchiveItem() {
  const { thread } = useLoaderData<typeof loader>()

  return (
    <Box>
      <ThreadItem thread={thread as Thread} />
    </Box>
  )
}
