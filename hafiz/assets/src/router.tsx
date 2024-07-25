import { Route, createBrowserRouter, createRoutesFromElements } from "react-router-dom"
import { AuthLayout, SignInPage, SignUpPage } from "~/routes/auth"
import { RootLayout } from "~/routes/root"

export const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path="/" element={<RootLayout />}>
      <Route>{/* app */}</Route>
      <Route path="auth" element={<AuthLayout />}>
        <Route path="signin" element={<SignInPage />} />
        <Route path="signup" element={<SignUpPage />} />
      </Route>
    </Route>
  )
)
