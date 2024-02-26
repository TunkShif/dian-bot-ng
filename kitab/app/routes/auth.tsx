import type { LinksFunction, LoaderFunctionArgs } from "@remix-run/cloudflare"
import { Outlet, redirect } from "@remix-run/react"
import { CameraIcon } from "lucide-react"
import { Box, Center, Flex } from "styled-system/jsx"
import { Logo } from "~/components/logo"
import { Icon } from "~/components/ui/icon"
import { Link } from "~/components/ui/link"
import { Text } from "~/components/ui/text"
import { CurrentUserQuery } from "~/services/auth-service"

import "@fontsource-variable/cinzel/wght.css"

export const links: LinksFunction = () => [{ rel: "prefetch", href: "/images/bg-books.jpg" }]

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const { data } = await client.query(CurrentUserQuery, {}).toPromise()
  if (data?.me.user) {
    return redirect("/")
  }

  return { ok: true }
}

export default function AuthLayout() {
  return (
    <Flex w="full" h="screen" flexDirection="column" lg={{ flexDirection: "row" }}>
      <CoverSection />
      <FormSection />
    </Flex>
  )
}

const CoverSection = () => {
  return (
    <Box
      flex="1"
      position="relative"
      backgroundImage="url('/images/bg-books.jpg')"
      backgroundSize="cover"
      _before={{
        content: "''",
        position: "absolute",
        inset: "0",
        bgColor: "gray.a11/75",
        _dark: { bgColor: "gray.a1/75" }
      }}
    >
      <Text
        size={["xs", "xs", "sm"]}
        position="absolute"
        top={["4", undefined, "8"]}
        left={["4", undefined, "8"]}
        color="accent.fg"
      >
        <Icon mr="2">
          <CameraIcon />
        </Icon>
        Photo by{" "}
        <Link
          color="accent.fg"
          href="https://unsplash.com/@rey_7?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
          target="_blank"
          rel="noreferrer"
        >
          Rey Seven
        </Link>
        {" on "}
        <Link
          color="accent.fg"
          href="https://unsplash.com/photos/brown-books-closeup-photography-_nm_mZ4Cs2I?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
          target="_blank"
          rel="noreferrer"
        >
          Unsplash
        </Link>
      </Text>
      <Text
        as="blockquote"
        size={["lg", "lg", "xl"]}
        position="absolute"
        right={["4", undefined, "8"]}
        bottom={["6", undefined, "8"]}
        color="accent.fg"
        textAlign="right"
        fontWeight="medium"
        fontFamily="cinzel"
        _before={{ content: "open-quote" }}
        _after={{ content: "close-quote" }}
      >
        Verba volant, sed littera scripta manet.
      </Text>
    </Box>
  )
}

const FormSection = () => {
  return (
    <Flex
      w="full"
      position="relative"
      flex="2"
      flexDirection="column"
      backgroundColor="bg.default"
      _before={{
        content: "''",
        position: "absolute",
        backgroundColor: "bg.default",
        roundedTop: "xl",
        insetX: "0",
        top: "-4",
        h: "4"
      }}
      lg={{
        flex: "1",
        translate: "none",
        borderRadius: "none",
        _before: {
          display: "none"
        }
      }}
    >
      <Flex mt="4" justify="center" align="center" lg={{ mt: "8", ml: "16", mr: "auto" }}>
        <Logo width="32" height="32" />
        <Text
          ml="1"
          fontFamily="silkscreen"
          textTransform="uppercase"
          letterSpacing="tight"
          userSelect="none"
        >
          Little Red Book
        </Text>
      </Flex>
      <Center flexGrow="1">
        <Outlet />
      </Center>
    </Flex>
  )
}
