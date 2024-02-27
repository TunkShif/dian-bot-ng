import { type MetaFunction } from "@remix-run/cloudflare"

export const meta: MetaFunction = () => {
  return [{ title: "Broadcast - LITTLE RED BOOK" }]
}

export default function Broadcast() {
  return <p>等通知</p>
}
