import { type LoaderFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Flex } from "styled-system/jsx"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  return {}
}

export default function Dashboard() {
  return <Flex p="8" fontSize="lg"></Flex>
}
