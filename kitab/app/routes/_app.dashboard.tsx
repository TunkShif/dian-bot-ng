import { type MetaFunction } from "@remix-run/cloudflare"
import { Link } from "@remix-run/react"
import { Box } from "styled-system/jsx"
import { Text } from "~/components/ui/text"
import { Link as StyledLink } from "~/components/ui/link"

export const meta: MetaFunction = () => {
  return [{ title: "Dashboard - LITTLE RED BOOK" }]
}

export default function Dashboard() {
  return (
    <Box p="8" fontSize="lg">
      <StyledLink asChild>
        <Link to="/login">登录</Link>
      </StyledLink>
      <Text>还没做好</Text>
    </Box>
  )
}
