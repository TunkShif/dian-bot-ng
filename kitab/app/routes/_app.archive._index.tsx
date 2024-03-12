import { parseWithZod } from "@conform-to/zod"
import { type LoaderFunctionArgs, json } from "@remix-run/cloudflare"
import { Link, useLoaderData } from "@remix-run/react"
import { ChevronLeftIcon, ChevronRightIcon } from "lucide-react"
import { Flex, Stack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { Button } from "~/components/ui/button"
import { createPaginationSchema } from "~/lib/pagination"
import { ThreadsQuery } from "~/queries/threads"
import { ThreadList } from "~/routes/_app.archive/thread-list"

const PAGE_SIZE = 8

const schema = createPaginationSchema(PAGE_SIZE)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const submission = parseWithZod(new URL(request.url).searchParams, { schema })
  invariant(submission.status === "success")

  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)
  const { data } = await client.query(ThreadsQuery, submission.value).toPromise()
  invariant(data)
  return json({ threads: data.threads.edges, pageInfo: data.threads.pageInfo })
}

export default function Archive() {
  const { pageInfo } = useLoaderData<typeof loader>()

  return (
    <Stack gap="6">
      <ThreadList />

      <Flex pb="4" w="full" justifyContent="end" gap="2">
        <Button
          size="sm"
          fontSize="xs"
          fontFamily="silkscreen"
          disabled={!pageInfo.hasPreviousPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasPreviousPage ? `/archive?before=${pageInfo.startCursor}` : "#"}>
            <ChevronLeftIcon />
            Prev
          </Link>
        </Button>

        <Button
          size="sm"
          fontSize="xs"
          fontFamily="silkscreen"
          disabled={!pageInfo.hasNextPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasNextPage ? `/archive?after=${pageInfo.endCursor}` : "#"}>
            <ChevronRightIcon />
            Next
          </Link>
        </Button>
      </Flex>
    </Stack>
  )
}
