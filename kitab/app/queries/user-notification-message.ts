import { graphql } from "gql"

export const UserNotficationMessageQuery = graphql(`
  query UserNotificationMessage {
    me {
      notificationMessage {
        id
        template
      }
    }
  }
`)
