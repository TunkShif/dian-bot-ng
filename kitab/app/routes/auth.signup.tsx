import { Portal } from "@ark-ui/react"
import { type ActionFunctionArgs, type MetaFunction } from "@remix-run/cloudflare"
import { Form, Link } from "@remix-run/react"
import { XIcon } from "lucide-react"
import { css } from "styled-system/css"
import { Box, Flex, HStack, Stack, VStack, styled } from "styled-system/jsx"
import { z } from "zod"
import { Button } from "~/components/ui/button"
import { Checkbox } from "~/components/ui/checkbox"
import { Heading } from "~/components/ui/heading"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"
import { Link as StyledLink } from "~/components/ui/link"
import * as Popover from "~/components/ui/popover"
import { Text } from "~/components/ui/text"

export const meta: MetaFunction = () => {
  return [{ title: "Signup - LITTLE RED BOOK" }]
}

export const action = async ({ request, context }: ActionFunctionArgs) => {
  // TODO: sign up
}

const formSchema = z.object({
  email: z
    .string()
    .max(20)
    .email("请输入正确的邮箱")
    .regex(/^\d{6,}@qq\.com$/, "请使用数字号码的企鹅邮箱"),
  agree: z.boolean()
})

export default function SignUp() {
  return (
    <Flex direction="column" justify="center" align="center" minW="sm">
      <Header />
      <SignUpForm />
      <Divider />
      <SignInButton />
    </Flex>
  )
}

const Header = () => (
  <>
    <Heading as="h1" size="xl">
      创建您的账户
    </Heading>
    <Text color="fg.subtle" mt="2" mb="4">
      请输入您账号对应的邮箱以便创建新账户
    </Text>
  </>
)

const SignUpForm = () => {
  return (
    <Form id="signup-form" className={css({ w: "4/5" })}>
      <VStack gap="4">
        <Input
          id="signup-form-email"
          w="full"
          name="email"
          type="email"
          placeholder="account@company.com"
          pattern="^\d{6,}@qq\.com$"
          maxLength={20}
          required
        />
        <Button type="submit" w="full">
          创建账户
        </Button>
        <AgreementsCheckbox />
      </VStack>
    </Form>
  )
}

const AgreementsCheckbox = () => (
  <HStack w="full" gap="0" alignItems="center">
    <Checkbox size="sm" id="signup-form-agree" name="agree" required>
      我已阅读并同意
    </Checkbox>
    <AgreementsPopover />
  </HStack>
)

const AgreementsPopover = () => (
  <Popover.Root>
    <Popover.Trigger asChild>
      <StyledLink display="inline-block" color="accent.text" fontSize="sm" fontWeight="bold">
        《用户协议》
      </StyledLink>
    </Popover.Trigger>
    <Portal>
      <Popover.Positioner>
        <Popover.Content>
          <Popover.Arrow>
            <Popover.ArrowTip />
          </Popover.Arrow>
          <Stack gap="1">
            <Popover.Title>用户注册须知</Popover.Title>
            <Popover.Description>
              本站在用户使用过程中会收集用户使用设备信息、基于IP地址的定位信息，以及仅限于本站注册用户范围内共享的用户使用动态记录。如果你不喜欢可以不用。
            </Popover.Description>
          </Stack>
          <Box position="absolute" top="1" right="1">
            <Popover.CloseTrigger asChild>
              <IconButton aria-label="关闭用户协议内容弹窗" variant="ghost" size="sm">
                <XIcon />
              </IconButton>
            </Popover.CloseTrigger>
          </Box>
        </Popover.Content>
      </Popover.Positioner>
    </Portal>
  </Popover.Root>
)

const Divider = () => (
  <HStack w="4/5" my="4">
    <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
    <Text size="sm" color="fg.subtle" flexShrink="0" fontWeight="light">
      已经拥有本站账户?
    </Text>
    <styled.div w="full" borderBlockEndWidth="1px" borderColor="border.subtle" />
  </HStack>
)

const SignInButton = () => (
  <Button variant="outline" w="4/5" asChild>
    <Link to="/auth/signin">用户登录</Link>
  </Button>
)
