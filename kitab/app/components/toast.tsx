import { createToaster } from "@ark-ui/react/toast"
import { XIcon } from "lucide-react"
import { IconButton } from "~/components/ui/icon-button"
import * as ToastPrimitives from "~/components/ui/toast"

const [Toaster, toast] = createToaster({
  placement: "top",
  render(toast) {
    return (
      <ToastPrimitives.Root>
        <ToastPrimitives.Title>{toast.title}</ToastPrimitives.Title>
        <ToastPrimitives.Description>{toast.description}</ToastPrimitives.Description>
        <ToastPrimitives.CloseTrigger asChild>
          <IconButton size="sm" variant="link">
            <XIcon />
          </IconButton>
        </ToastPrimitives.CloseTrigger>
      </ToastPrimitives.Root>
    )
  }
})

export { Toaster, toast }
