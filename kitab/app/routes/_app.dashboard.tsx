import { type MetaFunction } from "@vercel/remix"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

export default function Dashboard() {
  return "WIP"
}
