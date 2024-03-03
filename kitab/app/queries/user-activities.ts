import { graphql } from "gql"

export const UserActivitiesQuery = graphql(`
  query UserActivities($first: Int) {
    userActivities(first: $first) {
      edges {
        node {
          id
          location
          mouseX
          mouseY
          offlineAt
          user {
            id
            name
            qid
          }
        }
      }
    }
  }
`)
