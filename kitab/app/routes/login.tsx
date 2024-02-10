import { Center, Flex, HStack, VStack, styled } from "styled-system/jsx"
import { Heading } from "~/components/ui/heading"
import { Text } from "~/components/ui/text"
import { Form } from "@remix-run/react"
import { Input } from "~/components/ui/input"
import { Button } from "~/components/ui/button"
import { css } from "styled-system/css"

import "@fontsource/arvo/latin-400.css"

export default function Login() {
  return (
    <Flex w="full" h="screen">
      <CoverSection />
      <LoginSection />
    </Flex>
  )
}

const CoverSection = () => {
  return (
    <Flex
      direction="row"
      position="relative"
      p="8"
      flex="1"
      justify="end"
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
        as="blockquote"
        size="xl"
        position="relative"
        mt="auto"
        color="white"
        fontFamily="arvo"
        _before={{ content: "open-quote" }}
        _after={{ content: "close-quote" }}
      >
        Verba volant, sed littera scripta manet.
      </Text>
    </Flex>
  )
}

const LoginSection = () => {
  return (
    <Center flex="1">
      <Flex direction="column" justify="center" align="center" minW="sm">
        <Heading as="h1" size="xl">
          创建您的账户
        </Heading>
        <Text color="fg.subtle" mt="2" mb="4">
          请输入您账号对应的邮箱以便创建新账户
        </Text>
        <Form id="login-form" className={css({ w: "4/5" })}>
          <VStack>
            <Input name="email" placeholder="account@company.com" w="full" />
            <Button type="submit" w="full">
              创建账户
            </Button>
          </VStack>
        </Form>
        <HStack w="4/5" my="4">
          <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
          <Text size="sm" color="fg.subtle" flexShrink="0" fontWeight="light">
            已经拥有账户?
          </Text>
          <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
        </HStack>
        <Button variant="outline" w="4/5">
          用户登录
        </Button>
      </Flex>
    </Center>
  )
}
