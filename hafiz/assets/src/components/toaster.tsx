import { XIcon } from "lucide-react"
import { IconButton } from "~/components/ui/icon-button"
import * as Toast from "~/components/ui/toast"

// TODO: waiting for park-ui upgrade

export const toaster = Toast.createToaster({
  placement: "top-end",
  overlap: true,
  gap: 16
})

export const Toaster = () => {
  return (
    <Toast.Toaster toaster={toaster}>
      {(toast) => (
        <Toast.Root key={toast.id}>
          <Toast.Title>{toast.title}</Toast.Title>
          <Toast.Description>{toast.description}</Toast.Description>
          <Toast.CloseTrigger asChild>
            <IconButton size="xs" variant="ghost">
              <XIcon />
            </IconButton>
          </Toast.CloseTrigger>
        </Toast.Root>
      )}
    </Toast.Toaster>
  )
}
