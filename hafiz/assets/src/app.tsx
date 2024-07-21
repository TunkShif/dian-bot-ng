import { MantineProvider } from "@mantine/core"
import { Suspense } from "react"
import { RouterProvider } from "react-router-dom"
import { Provider as UrqlProvider } from "urql"
import { client } from "~/libs/urql"
import { router } from "~/router"
import { theme } from "~/theme"

export const App = () => {
  return (
    <MantineProvider theme={theme}>
      <Suspense>
        <UrqlProvider value={client}>
          <RouterProvider router={router} />
        </UrqlProvider>
      </Suspense>
    </MantineProvider>
  )
}
