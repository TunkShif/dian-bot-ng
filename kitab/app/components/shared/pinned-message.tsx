import { PinnedMessageType } from "gql/graphql"
import { AlertTriangleIcon, InfoIcon, SparklesIcon } from "lucide-react"

export const PINNED_MESSAGES_ICONS = {
  [PinnedMessageType.Info]: InfoIcon,
  [PinnedMessageType.Alert]: AlertTriangleIcon,
  [PinnedMessageType.News]: SparklesIcon
}

export const PINNED_MESSAGES_LABELS = {
  [PinnedMessageType.Info]: "通知",
  [PinnedMessageType.Alert]: "警告",
  [PinnedMessageType.News]: "更新"
}
