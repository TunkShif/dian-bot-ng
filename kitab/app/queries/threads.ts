import { graphql } from "gql"

export const ThreadsQuery = graphql(`
  query Threads($first: Int, $after: String, $last: Int, $before: String) {
    threads(first: $first, after: $after, last: $last, before: $before) {
      edges {
        node {
          group {
            gid
            id
            name
          }
          id
          messages {
            content {
              ... on AtMessageContent {
                __typename
                name
                qid
              }
              ... on ImageMessageContent {
                __typename
                url
                format
                width
                height
                blurredUrl
              }
              ... on TextMessageContent {
                __typename
                text
              }
            }
            id
            sender {
              id
              name
              qid
            }
            sentAt
          }
          owner {
            id
            name
            qid
          }
          postedAt
        }
      }
      pageInfo {
        startCursor
        hasNextPage
        hasPreviousPage
        endCursor
      }
    }
  }
`)
