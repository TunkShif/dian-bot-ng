import { graphql } from "gql"

export const CancelAccountMutation = graphql(`
  mutation CancelUserAccount($userId: ID!) {
    cancelUserAccount(id: $userId) {
      id
      qid
      name
      role
      registered
    }
  }
`)
