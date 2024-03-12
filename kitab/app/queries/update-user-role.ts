import { graphql } from "gql"

export const UpdateUserRoleMutation = graphql(`
  mutation UpdateUserRole($userId: ID!, $role: UserRole!) {
    updateUserRole(id: $userId, role: $role) {
      id
      qid
      name
      role
      registered
    }
  }
`)
