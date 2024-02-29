import { parseWithZod } from "@conform-to/zod"
import { json, type LoaderFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Link, useLoaderData } from "@remix-run/react"
import { graphql } from "gql"
import { ChevronLeftIcon, ChevronRightIcon } from "lucide-react"
import { Center, Flex } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { z } from "zod"
import { IconButton } from "~/components/ui/icon-button"
import { ThreadList } from "~/routes/_app.archive/thread-list"

export const meta: MetaFunction = () => {
  return [{ title: "Archive - LITTLE RED BOOK" }]
}

const ListThreadsQuery = graphql(`
  query ListThreads($first: Int, $after: String, $last: Int, $before: String) {
    threads(first: $first, after: $after, last: $last, before: $before) {
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
        startCursor
        hasNextPage
        hasPreviousPage
        endCursor
      }
    }
  }
`)

const PAGE_ITEM_SIZE = 8

const schema = z.union([
  z
    .object({
      before: z.string()
    })
    .transform((val) => ({ last: PAGE_ITEM_SIZE, before: val.before })),

  z
    .object({
      after: z.string()
    })
    .transform((val) => ({ first: PAGE_ITEM_SIZE, after: val.after })),
  z
    .object({})
    .strict()
    .transform(() => ({ first: 8 }))
])

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const submission = parseWithZod(new URL(request.url).searchParams, { schema })
  invariant(submission.status === "success")

  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const { data } = await client.query(ListThreadsQuery, submission.value).toPromise()
  invariant(data)
  return json({ threads: data.threads.edges, pageInfo: data.threads.pageInfo })
}

export default function Archive() {
  const { pageInfo } = useLoaderData<typeof loader>()

  return (
    <Center mx="4" flexDirection="column">
      <ThreadList />
      <Flex pb="4" w="full" maxW="lg" justifyContent="end" gap="2">
        <IconButton
          variant="outline"
          disabled={!pageInfo.hasPreviousPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasPreviousPage ? `/archive?before=${pageInfo.startCursor}` : "#"}>
            <ChevronLeftIcon />
          </Link>
        </IconButton>
        <IconButton
          variant="outline"
          disabled={!pageInfo.hasNextPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasNextPage ? `/archive?after=${pageInfo.endCursor}` : "#"}>
            <ChevronRightIcon />
          </Link>
        </IconButton>
      </Flex>
    </Center>
  )
}
