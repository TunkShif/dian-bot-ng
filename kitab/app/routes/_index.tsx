import { LoaderFunction, redirect, type MetaFunction } from "@remix-run/cloudflare"

export const meta: MetaFunction = () => {
  return [
    { title: "LITTLE RED BOOK" },
    { name: "description", content: "Welcome to LITTLE RED BOOK!" }
  ]
}

export const loader: LoaderFunction = () => {
  return redirect("/dashboard")
}
