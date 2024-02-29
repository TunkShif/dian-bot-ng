import { useLoaderData } from "@remix-run/react"
import type { Thread } from "gql/graphql"
import { VStack } from "styled-system/jsx"
import type { loader as archiveLoader } from "~/routes/_app.archive/route"
import { ThreadItem } from "~/routes/_app.archive/thread-item"

export const ThreadList = () => {
  const { threads } = useLoaderData<typeof archiveLoader>()

  return (
    <VStack maxW="lg" gap="6" py="4" lg={{ py: "8" }}>
      {threads.map((thread) => (
        <ThreadItem key={thread.node?.id} thread={thread.node as Thread} />
      ))}
    </VStack>
  )
}
