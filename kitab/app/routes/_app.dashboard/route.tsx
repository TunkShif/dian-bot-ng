import { defer, type LoaderFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Link } from "@remix-run/react"
import { graphql } from "gql"
import { Center, Flex, Stack, VStack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { Heading } from "~/components/ui/heading"
import { PinnedMessagesQuery } from "~/queries/pinned-messages"
import { DailyHeatMapCard } from "~/routes/_app.dashboard/daily-heatmap-card"
import { PinnedMessageList } from "~/routes/_app.dashboard/pinned-message-list"
import { RSSSubscriptionCard } from "~/routes/_app.dashboard/rss-subscription-card"
import { UserProfileCard } from "~/routes/_app.dashboard/user-profile-card"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

const UserStatisticsQuery = graphql(`
  query UserStatistics {
    me {
      statistics {
        chats
        threads
        followers
      }
    }
  }
`)

const DailyStatisticsQuery = graphql(`
  query DailyStatistics {
    statistics {
      dailyThreads {
        count
        date
      }
    }
  }
`)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const userStatisticsQuery = client.query(UserStatisticsQuery, {}).toPromise()
  const dailyStatisticsQuery = client.query(DailyStatisticsQuery, {}).toPromise()
  const pinnedMessagesQuery = client.query(PinnedMessagesQuery, { first: 5 }).toPromise()

  const userStatisticsResult = await userStatisticsQuery

  invariant(userStatisticsResult.data?.me)

  return defer({
    userStatistics: userStatisticsResult.data.me.statistics,
    dailyStatisticsQuery,
    pinnedMessagesQuery
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
