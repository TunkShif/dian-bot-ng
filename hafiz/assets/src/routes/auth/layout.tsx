import "@fontsource-variable/cinzel/wght.css"
import { Box, Flex } from "@mantine/core"
import { CameraIcon } from "lucide-react"
import { Outlet } from "react-router-dom"
import { Logo } from "~/components/logo"

export const AuthLayout = () => {
  return (
    <Flex w="full" h="screen" direction={{ base: "row", sm: "column", md: "column", lg: "row" }}>
      <CoverSection />
      <FormSection />
    </Flex>
  )
}

const CoverSection = () => {
  return <>foobar</>
  // return (
  //   <Box flex="1" pos="relative">
  //     <Box pos="absolute" inset="0" overflow="hidden">
  //       <styled.img
  //         position="absolute"
  //         inset="0"
  //         w="full"
  //         h="full"
  //         objectFit="cover"
  //         filter="auto"
  //         blur="lg"
  //         sepia="25%"
  //         grayscale="15%"
  //         brightness="60%"
  //         scale="auto"
  //         scaleX="1.1"
  //         scaleY="1.1"
  //         zIndex="-1"
  //         src="data:image/webp;base64,UklGRuIAAABXRUJQVlA4INYAAADwBwCdASpkAEMAP4Wkw12/tjgmtfytE/AwiWUGcA0Eg283KspRwnzbU8OcmUJb0POR9YiNEJ7WRLqmF4Igunj0UYfX/XF4ZLgA/up7xvscvPagV2G3afgWdyEkXJZxOfFBBWb5XdezUJ/0wuC9z5jE5Zw8JqW/7oONQxC6wt36sxC/4UP0F+suaxWSGqmJOBVYAxmM8YL2UVnM3sib6IscHp9s38ak+LsBZEjEG9oY86ryiUYHraTAjD0yC2LokbekrBH8u10JVHndm7bRhxWpfAtfAAAA"
  //         alt="blurred books"
  //         aria-hidden="true"
  //       />
  //       <styled.img
  //         w="full"
  //         h="full"
  //         objectFit="cover"
  //         filter="auto"
  //         sepia="25%"
  //         grayscale="15%"
  //         brightness="60%"
  //         src="/images/bg-books.webp"
  //         alt="books"
  //       />
  //     </Box>
  //     <Text
  //       size={["xs", "xs", "sm"]}
  //       position="absolute"
  //       top={["4", undefined, "8"]}
  //       left={["4", undefined, "8"]}
  //       color="accent.fg"
  //     >
  //       <Icon mr="2">
  //         <CameraIcon />
  //       </Icon>
  //       Photo by{" "}
  //       <Link
  //         color="accent.fg"
  //         href="https://unsplash.com/@rey_7?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
  //         target="_blank"
  //         rel="noreferrer"
  //       >
  //         Rey Seven
  //       </Link>
  //       {" on "}
  //       <Link
  //         color="accent.fg"
  //         href="https://unsplash.com/photos/brown-books-closeup-photography-_nm_mZ4Cs2I?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
  //         target="_blank"
  //         rel="noreferrer"
  //       >
  //         Unsplash
  //       </Link>
  //     </Text>
  //     <Text
  //       as="blockquote"
  //       size={["lg", "lg", "xl"]}
  //       position="absolute"
  //       right={["4", undefined, "8"]}
  //       bottom={["6", undefined, "8"]}
  //       color="accent.fg"
  //       textAlign="right"
  //       fontWeight="medium"
  //       fontFamily="cinzel"
  //       _before={{ content: "open-quote" }}
  //       _after={{ content: "close-quote" }}
  //     >
  //       Verba volant, sed littera scripta manet.
  //     </Text>
  //   </Box>
  // )
}

const FormSection = () => {
  return <>foobar</>
  // return (
  //   <Flex
  //     w="full"
  //     position="relative"
  //     flex="2"
  //     flexDirection="column"
  //     backgroundColor="bg.default"
  //     _before={{
  //       content: "''",
  //       position: "absolute",
  //       backgroundColor: "bg.default",
  //       roundedTop: "xl",
  //       insetX: "0",
  //       top: "-4",
  //       h: "4"
  //     }}
  //     lg={{
  //       flex: "1",
  //       translate: "none",
  //       borderRadius: "none",
  //       _before: {
  //         display: "none"
  //       }
  //     }}
  //   >
  //     <Flex mt="4" justify="center" align="center" lg={{ mt: "8", ml: "16", mr: "auto" }}>
  //       <Logo width="32" height="32" />
  //       <Text
  //         ml="1"
  //         fontFamily="silkscreen"
  //         textTransform="uppercase"
  //         letterSpacing="tight"
  //         userSelect="none"
  //       >
  //         Little Red Book
  //       </Text>
  //     </Flex>
  //     <Center flexGrow="1">
  //       <Outlet />
  //     </Center>
  //   </Flex>
  // )
}
