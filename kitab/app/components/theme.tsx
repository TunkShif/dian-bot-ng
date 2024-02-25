import { Portal } from "@ark-ui/react"
import { parseWithZod } from "@conform-to/zod"
import { useFetcher, useRouteLoaderData } from "@remix-run/react"
import { MoonIcon, SunIcon } from "lucide-react"
import { center } from "styled-system/patterns"
import invariant from "tiny-invariant"
import { z } from "zod"
import { IconButton } from "~/components/ui/icon-button"
import * as Tooltip from "~/components/ui/tooltip"
import { useHints } from "~/lib/client-hints"
import type { loader as rootLoader } from "~/root"

const THEME_FETCHER_KEY = "THEME_FETCHER"

export const themeSchema = z.enum(["system", "light", "dark"]).default("system")

export type ThemeSchema = z.infer<typeof themeSchema>

export const themeFormSchema = z.object({
  theme: themeSchema
})

export type ThemeFormSchema = z.infer<typeof themeFormSchema>

export const ThemeToggleButton = () => {
  const fetcher = useFetcher({ key: THEME_FETCHER_KEY })
  const theme = useTheme()

  return (
    <fetcher.Form method="post" action="/actions/theme" className={center()}>
      <Tooltip.Root>
        <Tooltip.Trigger asChild>
          <IconButton
            variant="ghost"
            name="theme"
            value={theme === "light" ? "dark" : "light"}
            type="submit"
          >
            {theme === "light" && <SunIcon />}
            {theme === "dark" && <MoonIcon />}
          </IconButton>
        </Tooltip.Trigger>
        <Portal>
          <Tooltip.Positioner>
            <Tooltip.Content>切换主题</Tooltip.Content>
          </Tooltip.Positioner>
        </Portal>
      </Tooltip.Root>
    </fetcher.Form>
  )
}

export const useTheme = () => {
  const hints = useHints()
  const data = useRouteLoaderData<typeof rootLoader>("root")
  invariant(data?.theme, "No theme found in root loader.")

  const optimisticValue = useOptimisticTheme()
  if (optimisticValue) {
    return optimisticValue === "system" ? hints.theme : optimisticValue
  }

  return data.theme === "system" ? hints.theme : data.theme
}

const useOptimisticTheme = () => {
  const fetcher = useFetcher({ key: THEME_FETCHER_KEY })

  if (fetcher.formData) {
    const submission = parseWithZod(fetcher.formData, { schema: themeFormSchema })

    if (submission.status === "success") {
      return submission.value.theme
    }
  }
}
