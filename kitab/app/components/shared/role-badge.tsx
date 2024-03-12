import { UserRole } from "gql/graphql"
import { Badge, type BadgeProps } from "~/components/ui/badge"

const USER_ROLE_LABELS = {
  [UserRole.User]: "普通用户",
  [UserRole.Admin]: "SVIP"
}

type RoleBadgeProps = {
  userRole: UserRole
} & BadgeProps

export const RoleBadge = ({ userRole, ...props }: RoleBadgeProps) => {
  switch (userRole) {
    case UserRole.Admin:
      return (
        <Badge variant="outline" bg="gold.8" color="accent.fg" borderColor="gold.4" {...props}>
          {USER_ROLE_LABELS[userRole]}
        </Badge>
      )
    case UserRole.User:
      return (
        <Badge variant="outline" bg="jade.8" color="accent.fg" borderColor="jade.4" {...props}>
          {USER_ROLE_LABELS[userRole]}
        </Badge>
      )
  }
}
