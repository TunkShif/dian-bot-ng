import { graphql } from "gql"

export const UserStatisticsQuery = graphql(`
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
