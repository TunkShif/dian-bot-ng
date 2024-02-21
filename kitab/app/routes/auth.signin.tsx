import { type ActionFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Form, Link } from "@remix-run/react"
import { css } from "styled-system/css"
import { Flex, Stack, VStack } from "styled-system/jsx"
import { Button } from "~/components/ui/button"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { Input } from "~/components/ui/input"
import { Link as StyledLink } from "~/components/ui/link"

export const meta: MetaFunction = () => {
  return [{ title: "Signin - LITTLE RED BOOK" }]
}

export const action = async ({ request, context }: ActionFunctionArgs) => {
  // TODO: sign in
}

export default function SignUp() {
  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Heading as="h1" size="xl" mb="4">
        👋 Welcome back!
      </Heading>
      <SignInForm />
    </Flex>
  )
}

const SignInForm = () => {
  return (
    <Form id="signin-form" className={css({ w: "4/5" })}>
      <VStack gap="4">
        <Stack w="full" gap="1.5">
          <FormLabel>账号</FormLabel>
          <Input
            name="qid"
            type="text"
            placeholder="Your QQ Number"
            pattern="^\d{6,}$"
            maxLength={12}
            required
          />
        </Stack>
        <Stack w="full" gap="1.5">
          <FormLabel>密码</FormLabel>
          <Input name="password" type="password" placeholder="Not Your QQ Password" required />
        </Stack>
        <Button type="submit" w="full">
          登录
        </Button>
        <StyledLink w="full" textAlign="right" fontSize="sm" asChild>
          <Link to="/auth/signup">还没有本站账户?</Link>
        </StyledLink>
      </VStack>
    </Form>
  )
}
