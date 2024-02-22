import { useEffect } from "react"
import { toast } from "sonner"
import type { ToastSchema } from "~/lib/toast.server"

const showToast = (toastOptions: ToastSchema) => {
  const { id, type, title, description } = toastOptions
  switch (type) {
    case "success":
      toast.success(title, { id, description })
      break
    case "error":
      toast.error(title, { id, description })
      break
    case "default":
      toast(title, { id, description })
  }
}

export const useToast = (toastOptions: ToastSchema | null) => {
  useEffect(() => {
    if (toastOptions) {
      setTimeout(() => showToast(toastOptions), 0)
    }
  }, [toastOptions])
}
