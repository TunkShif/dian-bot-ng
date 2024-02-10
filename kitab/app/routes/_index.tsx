import { LoaderFunction, redirect, type MetaFunction } from "@vercel/remix"

export const meta: MetaFunction = () => {
  return [
    { title: "LITTLE RED BOOK" },
    { name: "description", content: "Welcome to LITTLE RED BOOK!" }
  ]
}

export const loader: LoaderFunction = () => {
  return redirect("/dashboard")
}
