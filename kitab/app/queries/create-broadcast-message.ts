import { graphql } from "gql"

export const CreateBroadcastMessageMutation = graphql(`
  mutation CreateBroadcastMessage($groupId: String!, $message: String!) {
    createBroadcastMessage(groupId: $groupId, message: $message)
  }
`)
