import { graphql } from "gql"

export const UsersQuery = graphql(`
  query Users($first: Int, $after: String, $before: String, $last: Int) {
    users(first: $first, after: $after, before: $before, last: $last) {
      edges {
        node {
          id
          name
          qid
          role
          registered
          statistics {
            chats
            threads
            followers
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
