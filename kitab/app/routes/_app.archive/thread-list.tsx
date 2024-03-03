import { useLoaderData } from "@remix-run/react"
import type { Thread } from "gql/graphql"
import { Flex } from "styled-system/jsx"
import type { loader as archiveLoader } from "~/routes/_app.archive._index"
import { ThreadItem } from "~/routes/_app.archive/thread-item"

export const ThreadList = () => {
  const { threads } = useLoaderData<typeof archiveLoader>()

  return (
    <Flex
      w="full"
      gap="6"
      flexDirection="column"
      lg={{ display: "block", columns: 2, columnGap: "6", "& > * + *": { mt: "6" } }}
    >
      {threads.map((thread) => (
        <ThreadItem key={thread.node?.id} thread={thread.node as Thread} />
      ))}
    </Flex>
  )
}
