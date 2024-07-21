import { Link } from "react-router-dom"
import z from "zod"

export const schema = z.object({
  qid: z
    .string({ required_error: "请输入你的企鹅账号" })
    .min(5, "请输入正确的账号")
    .max(12, "请输入正确的账号")
    .regex(/^\d{6,}$/, "请输入正确的账号"),
  password: z.string({ required_error: "请输入你的本站密码" })
})

export const SignInPage = () => {
  return <>sign in page</>
  // return (
  //   <Flex direction="column" justify="center" align="center" minW="sm">
  //     <Heading as="h1" size="xl" mb="4">
  //       👋 Welcome back!
  //     </Heading>
  //     <SignInForm />
  //   </Flex>
  // )
}

const SignInForm = () => {
  return (
    <form method="post" className={css({ w: "4/5" })}>
      <VStack gap="4">
        <Stack w="full" gap="1.5">
          <FormLabel>账号</FormLabel>
          <Input placeholder="Your QQ Number" />
        </Stack>
        <Stack w="full" gap="1.5">
          <FormLabel>密码</FormLabel>
          <Input autoComplete="current-password" placeholder="Not Your QQ Password" />
        </Stack>
        <Button type="submit" w="full">
          登录
        </Button>
        <StyledLink w="full" textAlign="right" fontSize="sm" asChild>
          <Link to="/auth/signup">还没有本站账户?</Link>
        </StyledLink>
      </VStack>
    </form>
  )
}
