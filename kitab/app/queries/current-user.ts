import { graphql } from "gql"

export const CurrentUserQuery = graphql(`
  query CurrentUser {
    me {
      user {
        id
        qid
        name
        role
      }
      perms
      token
    }
  }
`)
