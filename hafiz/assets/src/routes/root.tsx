import { Outlet } from "react-router-dom"
import { Fragment } from "react/jsx-runtime"
import { Toaster } from "~/components/toaster"

export const Root = () => {
  return (
    <Fragment>
      <Outlet />
      <Toaster />
    </Fragment>
  )
}
