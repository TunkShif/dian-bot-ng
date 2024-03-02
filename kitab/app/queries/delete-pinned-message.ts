import { graphql } from "gql"

export const DeletePinnedMessageMutation = graphql(`
  mutation DeletePinnedMessage($id: ID!) {
    deletePinnedMessage(id: $id) {
      id
    }
  }
`)
