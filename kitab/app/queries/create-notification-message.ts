import { graphql } from "gql"

export const CreateNotificationMessageMutation = graphql(`
  mutation CreateNotificationMessage($template: String!) {
    createNotificationMessage(template: $template) {
      id
      template
      operator {
        id
        qid
        name
      }
    }
  }
`)
