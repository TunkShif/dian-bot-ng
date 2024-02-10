import { MetaFunction } from "@remix-run/cloudflare"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - Dian" }]
}

export default function Dashboard() {
  return "foobar"
}
