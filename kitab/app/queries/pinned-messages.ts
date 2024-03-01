import { graphql } from "gql"

export const PinnedMessagesQuery = graphql(`
  query PinnedMessages($first: Int) {
    pinnedMessages(first: $first) {
      edges {
        node {
          id
          type
          title
          content
          operator {
            id
            qid
            name
          }
        }
      }
    }
  }
`)
