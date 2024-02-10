import { type MetaFunction } from "@vercel/remix"
import { Box } from "styled-system/jsx"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

export default function Dashboard() {
  return (
    <Box p="8" fontSize="5xl">
      还没做好
    </Box>
  )
}
