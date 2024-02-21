import { Outlet } from "@remix-run/react"
import { CameraIcon } from "lucide-react"
import { Box, Center, Flex } from "styled-system/jsx"
import { Logo } from "~/components/logo"
import { Icon } from "~/components/ui/icon"
import { Link } from "~/components/ui/link"
import { Text } from "~/components/ui/text"

import "@fontsource-variable/cinzel/wght.css"

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
        bgColor: "gray.a11/75"
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
    <Center
      position="relative"
      flex="2"
      backgroundColor="bg.default"
      _before={{
        content: "''",
        position: "absolute",
        backgroundColor: "white",
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
      <Flex
        position="absolute"
        justify="center"
        align="center"
        top="8"
        left="0"
        right="0"
        lg={{ top: "12", left: "16", right: "auto" }}
      >
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
      <Outlet />
    </Center>
  )
}
