import { graphql } from "gql"

export const NotificationMessagesQuery = graphql(`
  query NotificationMessages($first: Int, $last: Int, $before: String, $after: String) {
    notificationMessages(first: $first, last: $last, before: $before, after: $after) {
      edges {
        node {
          id
          template
          operator {
            id
            qid
            name
          }
        }
      }
      pageInfo {
        endCursor
        hasNextPage
        hasPreviousPage
        startCursor
      }
    }
  }
`)
