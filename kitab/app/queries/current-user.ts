import { graphql } from "gql"

export const CurrentUserQuery = graphql(`
  query CurrentUser {
    me {
      user {
        id
        qid
        role
        name
      }
      token
    }
  }
`)
