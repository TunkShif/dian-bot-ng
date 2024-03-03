import { graphql } from "gql"

export const BotStatusQuery = graphql(`
  query BotStatus {
    bot {
      isOnline
    }
  }
`)
