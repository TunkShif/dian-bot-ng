import { Suspense } from "react"
import {
  Route,
  RouterProvider,
  createBrowserRouter,
  createRoutesFromElements
} from "react-router-dom"
import { Provider as UrqlProvider } from "urql"
import { client } from "~/libs/urql"
import { Auth } from "~/routes/auth/layout"
import { SignIn } from "~/routes/auth/signin"
import { SignUp, signUpAction } from "~/routes/auth/signup"
import { Root } from "~/routes/root"

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path="/" element={<Root />}>
      <Route>{/* app */}</Route>
      <Route path="auth" element={<Auth />}>
        <Route path="signin" element={<SignIn />} />
        <Route path="signup" element={<SignUp />} action={signUpAction} />
      </Route>
    </Route>
  )
)

export const App = () => {
  return (
    <Suspense>
      <UrqlProvider value={client}>
        <RouterProvider router={router} />
      </UrqlProvider>
    </Suspense>
  )
}
