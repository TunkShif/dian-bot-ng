import { Portal } from "@ark-ui/react"
import type { ReactNode } from "react"
import * as TooltipPrimitives from "~/components/ui/tooltip"

export type TooltipProps = Omit<TooltipPrimitives.RootProps, "children"> & {
  content: string
  children: ReactNode
}

export const Tooltip = ({ content, children, ...rest }: TooltipProps) => {
  return (
    <TooltipPrimitives.Root openDelay={200} {...rest}>
      <TooltipPrimitives.Trigger asChild>{children}</TooltipPrimitives.Trigger>
      <Portal>
        <TooltipPrimitives.Positioner>
          <TooltipPrimitives.Content>{content}</TooltipPrimitives.Content>
        </TooltipPrimitives.Positioner>
      </Portal>
    </TooltipPrimitives.Root>
  )
}
