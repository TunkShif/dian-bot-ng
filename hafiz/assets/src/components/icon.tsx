import { LoaderCircleIcon } from "lucide-react"
import { Icon, type IconProps } from "~/components/ui/icon"

export const SpinnerIcon = (props: Omit<IconProps, "children">) => (
  <Icon animation="spin 1s linear infinite" {...props}>
    <LoaderCircleIcon />
  </Icon>
)
