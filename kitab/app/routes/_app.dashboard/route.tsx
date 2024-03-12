import { type LoaderFunctionArgs, type MetaFunction, defer } from "@remix-run/cloudflare"
import { Link } from "@remix-run/react"
import { Center, Flex, Stack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { Heading } from "~/components/ui/heading"
import { DailyThreadsStatisticsQuery } from "~/queries/daily-threads-statistics"
import { PinnedMessagesQuery } from "~/queries/pinned-messages"
import { UserStatisticsQuery } from "~/queries/user-statistics"
import { DailyHeatMapCard } from "~/routes/_app.dashboard/daily-heatmap-card"
import { PinnedMessageList } from "~/routes/_app.dashboard/pinned-message-list"
import { RSSSubscriptionCard } from "~/routes/_app.dashboard/rss-subscription-card"
import { UserProfileCard } from "~/routes/_app.dashboard/user-profile-card"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const userStatisticsQuery = client.query(UserStatisticsQuery, {}).toPromise()
  const dailyStatisticsQuery = client.query(DailyThreadsStatisticsQuery, {}).toPromise()
  const pinnedMessagesQuery = client.query(PinnedMessagesQuery, { first: 5 }).toPromise()

  const [userStatisticsResult, dailyStatisticsResult, pinnedMessagesResult] = await Promise.all([
    userStatisticsQuery,
    dailyStatisticsQuery,
    pinnedMessagesQuery
  ])

  invariant(userStatisticsResult.data?.me?.user?.statistics)
  invariant(dailyStatisticsResult.data)
  invariant(pinnedMessagesResult.data)

  return defer({
    userStatistics: userStatisticsResult.data.me.user.statistics,
    dailyStatistics: dailyStatisticsResult.data.dailyThreadsStatistics,
    pinnedMessages: pinnedMessagesResult.data.pinnedMessages.edges
  })
}

export default function Dashboard() {
  return (
    <Center mx="4" py="4" lg={{ py: "8" }}>
      <Flex w="full" flexDirection="column" lg={{ flexDirection: "row", maxW: "5xl" }} gap="8">
        <Stack flex="2" gap="6">
          <Link to="/dashboard">
            <Heading
              color="accent.emphasized"
              w="full"
              fontFamily="silkscreen"
              fontSize="2xl"
              as="h2"
            >
              Dashboard
            </Heading>
          </Link>

          <PinnedMessageList />

          <VStack w="full">
            <DailyHeatMapCard />
          </VStack>
        </Stack>

        <Stack display="none" lg={{ display: "flex" }} flex="1" gap="6">
          <UserProfileCard />
          <RSSSubscriptionCard />
        </Stack>
      </Flex>
    </Center>
  )
}
