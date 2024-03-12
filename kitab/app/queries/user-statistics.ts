import { graphql } from "gql"

export const UserStatisticsQuery = graphql(`
  query UserStatistics {
    me {
      user {
        statistics {
          chats
          threads
          followers
        }
      }
    }
  }
`)
