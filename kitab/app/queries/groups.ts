import { graphql } from "gql"

export const GroupsQuery = graphql(`
  query Groups($after: String, $before: String, $first: Int, $last: Int) {
    groups(after: $after, before: $before, first: $first, last: $last) {
      edges {
        node {
          gid
          name
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
