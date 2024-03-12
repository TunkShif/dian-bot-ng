import type { MetaFunction } from "@remix-run/cloudflare"
import { Link, Outlet } from "@remix-run/react"
import { Center, Stack } from "styled-system/jsx"
import { Heading } from "~/components/ui/heading"

export const meta: MetaFunction = () => {
  return [{ title: "Archive - LITTLE RED BOOK" }]
}

export default function Archive() {
  return (
    <Center mx="4" py="4" lg={{ py: "8" }}>
      <Stack w="full" maxW="5xl" gap="6">
        <Link to="/archive">
          <Heading
            color="accent.emphasized"
            w="full"
            fontFamily="silkscreen"
            fontSize="2xl"
            as="h2"
          >
            Archive
          </Heading>
        </Link>

        <Outlet />
      </Stack>
    </Center>
  )
}
