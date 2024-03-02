import { graphql } from "gql"

export const CreatePinnedMessageMutation = graphql(`
  mutation CreatePinnedMessage($content: String!, $type: PinnedMessageType!, $title: String!) {
    createPinnedMessage(content: $content, type: $type, title: $title) {
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
`)
