import { graphql } from "gql"

export const DailyThreadsStatisticsQuery = graphql(`
  query DailyStatistics {
    dailyThreadsStatistics {
      count
      date
    }
  }
`)
