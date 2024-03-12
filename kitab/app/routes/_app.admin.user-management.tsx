import { Portal } from "@ark-ui/react"
import { parseWithZod } from "@conform-to/zod"
import {
  type ActionFunctionArgs,
  type LoaderFunctionArgs,
  type MetaFunction,
  json
} from "@remix-run/cloudflare"
import { Link, useFetcher, useLoaderData } from "@remix-run/react"
import { createContextState } from "foxact/context-state"
import { type User, UserRole } from "gql/graphql"
import { XIcon } from "lucide-react"
import { useEffect } from "react"
import { Box, HStack, Stack } from "styled-system/jsx"
import invariant from "tiny-invariant"
import { z } from "zod"
import { RoleBadge } from "~/components/shared/role-badge"
import { Spinner } from "~/components/shared/spinner"
import { Tooltip } from "~/components/shared/tooltip"
import { Avatar } from "~/components/ui/avatar"
import { Badge } from "~/components/ui/badge"
import { Button } from "~/components/ui/button"
import { FormLabel } from "~/components/ui/form-label"
import { Heading } from "~/components/ui/heading"
import { IconButton } from "~/components/ui/icon-button"
import * as Popover from "~/components/ui/popover"
import * as RadioGroup from "~/components/ui/radio-group"
import * as Table from "~/components/ui/table"
import { Text } from "~/components/ui/text"
import { createPaginationSchema } from "~/lib/pagination"
import { CancelAccountMutation } from "~/queries/cancel-account"
import { UpdateUserRoleMutation } from "~/queries/update-user-role"
import { UsersQuery } from "~/queries/users"

export const meta: MetaFunction = () => {
  return [{ title: "User Management - LITTLE RED BOOK" }]
}

const schema = z.union([
  z.object({
    intent: z.literal("cancel-account"),
    userId: z.string()
  }),
  z.object({
    intent: z.literal("update-role"),
    userId: z.string(),
    role: z.nativeEnum(UserRole)
  })
])

export const action = async ({ request, context }: ActionFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const formData = await request.formData()
  const submission = parseWithZod(formData, { schema })

  if (submission.status !== "success") {
    return json({ success: false, errors: submission.reply() })
  }

  switch (submission.value.intent) {
    case "cancel-account": {
      const result = await client.mutation(CancelAccountMutation, submission.value).toPromise()
      return json({
        success: result.data?.cancelUserAccount != null,
        errors: submission.reply()
      })
    }
    case "update-role": {
      const result = await client.mutation(UpdateUserRoleMutation, submission.value).toPromise()
      return json({
        success: result.data?.updateUserRole != null,
        errors: submission.reply()
      })
    }
  }
}

const PAGE_SIZE = 8
const searchParamsSchema = createPaginationSchema(PAGE_SIZE)

export const loader = async ({ request, context }: LoaderFunctionArgs) => {
  const token = await context.sessionStorage.getUserToken(request)
  const client = context.client.createGraphQLClient(token)

  const searchParams = new URL(request.url).searchParams

  const submission = parseWithZod(searchParams, { schema: searchParamsSchema })
  invariant(submission.status === "success")

  const usersResult = await client.query(UsersQuery, submission.value).toPromise()
  invariant(usersResult.data)

  return json({
    users: usersResult.data.users.edges,
    pageInfo: usersResult.data.users.pageInfo
  })
}

export const useUserManagementLoaderData = () => useLoaderData<typeof loader>()

export default function UserManagement() {
  return (
    <Stack p="2">
      <Header />
      <UserTable />
      <Pagination />
    </Stack>
  )
}

const Header = () => {
  return (
    <Stack gap="2">
      <Heading as="h3">站内用户管理</Heading>
      <Text color="fg.subtle" size="sm">
        管理本站记录过的所有用户
      </Text>
    </Stack>
  )
}

const UserTable = () => {
  const { users } = useUserManagementLoaderData()

  return (
    <Box overflowX="auto">
      <Table.Root position="relative" minW="2xl">
        <Table.Head>
          <Table.Row>
            <Table.Header color="fg.default" position="sticky" left="0" bg="bg.default">
              昵称
            </Table.Header>
            <Table.Header>账号</Table.Header>
            <Table.Header>分组</Table.Header>
            <Table.Header textAlign="center">发言</Table.Header>
            <Table.Header textAlign="center">入典</Table.Header>
            <Table.Header textAlign="center">粉丝</Table.Header>
            <Table.Header textAlign="right">操作</Table.Header>
          </Table.Row>
        </Table.Head>
        <Table.Body>
          {users.map((user) => (
            <Table.Row key={user.node.id}>
              <Table.Cell position="sticky" left="0" bg="bg.default">
                <HStack>
                  <Avatar
                    size="xs"
                    src={`/avatar/${user.node.qid}`}
                    name={user.node.name}
                    borderWidth="1"
                  />
                  <Text size="sm" fontWeight="medium" maxW="12ch" truncate title={user.node.name}>
                    {user.node.name}
                  </Text>
                </HStack>
              </Table.Cell>
              <Table.Cell>{user.node.qid}</Table.Cell>
              <Table.Cell>
                {user.node.registered ? (
                  <RoleBadge userRole={user.node.role} fontSize="0.65rem" />
                ) : (
                  <Badge fontSize="0.65rem">未注册</Badge>
                )}
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Text fontVariantNumeric="tabular-nums">{user.node.statistics.chats}</Text>
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Text fontVariantNumeric="tabular-nums">{user.node.statistics.threads}</Text>
              </Table.Cell>
              <Table.Cell textAlign="center">
                <Text fontVariantNumeric="tabular-nums">{user.node.statistics.followers}</Text>
              </Table.Cell>
              <Table.Cell textAlign="right">
                <ActionProvider>
                  <EditUserAction user={user.node as User} />
                </ActionProvider>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table.Body>
      </Table.Root>
    </Box>
  )
}

const Pagination = () => {
  const { pageInfo } = useUserManagementLoaderData()
  return (
    <HStack justifyContent="end">
      <Box>
        <Button
          variant="outline"
          size="xs"
          display="inline-flex"
          roundedRight="none"
          disabled={!pageInfo.hasPreviousPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasPreviousPage ? `?before=${pageInfo.startCursor}` : "#"}>
            上一页
          </Link>
        </Button>
        <Button
          variant="outline"
          size="xs"
          display="inline-flex"
          roundedLeft="none"
          borderLeftWidth="0"
          disabled={!pageInfo.hasNextPage}
          _disabled={{ pointerEvents: "none" }}
          asChild
        >
          <Link to={pageInfo.hasNextPage ? `?after=${pageInfo.endCursor}` : "#"}>下一页</Link>
        </Button>
      </Box>
    </HStack>
  )
}

const [ActionProvider, useIsOpen, useSetIsOpen] = createContextState(false)

const EditUserAction = ({ user }: { user: User }) => {
  const isOpen = useIsOpen()
  const setIsOpen = useSetIsOpen()

  return (
    <Popover.Root open={isOpen} onOpenChange={(e) => setIsOpen(e.open)}>
      <Popover.Trigger asChild>
        <Button size="sm" variant="link" color="accent.text">
          编辑
        </Button>
      </Popover.Trigger>
      <Portal>
        <Popover.Positioner>
          <Popover.Content minW="xs">
            <Popover.Arrow>
              <Popover.ArrowTip />
            </Popover.Arrow>

            <Stack>
              <Stack gap="1">
                <Popover.Title>用户管理</Popover.Title>
                <Popover.Description>编辑用户组、取消用户注册</Popover.Description>
              </Stack>

              <Box h="1" borderBottomWidth="1" mx="-4" />

              <UpdateRoleForm user={user} />

              <Box h="1" borderBottomWidth="1" mx="-4" />

              <HStack justifyContent="end">
                <CancelAccountAction user={user} />
                <UpdateRoleAction user={user} />
              </HStack>
            </Stack>

            <Box position="absolute" top="1" right="1">
              <Popover.CloseTrigger asChild>
                <IconButton aria-label="关闭用户弹窗" variant="ghost" size="xs">
                  <XIcon />
                </IconButton>
              </Popover.CloseTrigger>
            </Box>
          </Popover.Content>
        </Popover.Positioner>
      </Portal>
    </Popover.Root>
  )
}

const roles = [
  { key: "user", value: UserRole.User, label: "普通用户" },
  { key: "admin", value: UserRole.Admin, label: "SVIP" }
]

const UpdateRoleForm = ({ user }: { user: User }) => {
  const fetcher = useFetcher({ key: `update-role:${user.id}` })

  return (
    <fetcher.Form id={`update-role-${user.qid}`} method="post">
      <input type="hidden" name="userId" value={user.id} />
      <Stack gap="1.5">
        <FormLabel size="sm">用户分组</FormLabel>
        <RadioGroup.Root size="sm" orientation="horizontal" name="role" defaultValue={user.role}>
          {roles.map((role) => (
            <RadioGroup.Item key={role.key} value={role.value}>
              <RadioGroup.ItemControl />
              <RadioGroup.ItemText>{role.label}</RadioGroup.ItemText>
            </RadioGroup.Item>
          ))}
        </RadioGroup.Root>
      </Stack>
    </fetcher.Form>
  )
}

const UpdateRoleAction = ({ user }: { user: User }) => {
  const setIsOpen = useSetIsOpen()

  const fetcher = useFetcher<typeof action>({ key: `update-role:${user.id}` })
  const isSubmitting = fetcher.state !== "idle"
  const isSubmissionSuccess = fetcher.state === "idle" && fetcher.data?.success

  useEffect(() => {
    if (isSubmissionSuccess) {
      setIsOpen(false)
    }
  }, [setIsOpen, isSubmissionSuccess])

  return (
    <Button
      size="xs"
      form={`update-role-${user.qid}`}
      name="intent"
      value="update-role"
      disabled={isSubmitting}
    >
      {isSubmitting && <Spinner size="xs" />}
      保存
    </Button>
  )
}

const CancelAccountAction = ({ user }: { user: User }) => {
  const setIsOpen = useSetIsOpen()
  const fetcher = useFetcher<typeof action>({ key: `cancel-account:${user.id}` })

  const isSubmitting = fetcher.state !== "idle"
  const isSubmissionSuccess = fetcher.state === "idle" && fetcher.data?.success

  useEffect(() => {
    if (isSubmissionSuccess) {
      setIsOpen(false)
    }
  }, [setIsOpen, isSubmissionSuccess])

  return (
    <fetcher.Form id={`cancel-account-${user.qid}`} method="post">
      <input type="hidden" name="userId" value={user.id} />

      <Tooltip content="注销当前用户，该用户注销以后需要重新注册">
        <Button
          variant="outline"
          size="xs"
          disabled={!user.registered || isSubmitting}
          name="intent"
          value="cancel-account"
        >
          {isSubmitting && <Spinner size="xs" />}
          注销
        </Button>
      </Tooltip>
    </fetcher.Form>
  )
}
