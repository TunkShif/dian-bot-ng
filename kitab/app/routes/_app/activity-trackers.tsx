import { Portal } from "@ark-ui/react"
import { Await, useLocation } from "@remix-run/react"
import { intlFormatDistance } from "date-fns"
import { SVGProps, Suspense, forwardRef } from "react"
import { Box, HStack, Stack } from "styled-system/jsx"
import { Avatar } from "~/components/ui/avatar"
import { Icon } from "~/components/ui/icon"
import { Text } from "~/components/ui/text"
import { useAppLoaderData } from "~/routes/_app/route"

// TODO: styling

export const ActivityTrackers = () => {
  return (
    <Portal>
      <Box position="relative" zIndex="popover">
        <HistoryTrackers />
      </Box>
    </Portal>
  )
}

const HistoryTrackers = () => {
  const { userActivitiesQuery } = useAppLoaderData()
  return (
    <ul>
      <Suspense>
        <Await resolve={userActivitiesQuery}>
          {(userActivities) =>
            userActivities.data?.userActivities.edges.map(({ node }) => {
              const distance = intlFormatDistance(new Date(node.offlineAt), new Date(), {
                locale: "zh-Hans-CN"
              })
              return (
                <li key={node.id}>
                  <CursorIndicator
                    x={node.mouseX}
                    y={node.mouseY}
                    name={node.user.name}
                    qid={node.user.qid}
                    text={`${distance}到此一游`}
                    location={node.location}
                  />
                </li>
              )
            })
          }
        </Await>
      </Suspense>
    </ul>
  )
}

const CursorIndicator = ({
  x,
  y,
  qid,
  name,
  text,
  location
}: { location: string; x: number; y: number; qid: string; name: string; text: string }) => {
  if (useLocation().pathname !== location) return null

  return (
    <Box position="fixed" style={{ left: `${x}%`, top: `${y}%` }}>
      <HStack>
        <Icon size="lg" rotate="-20deg" color="accent.text">
          <CursorIcon />
        </Icon>
        <Box bg="bg.default" borderWidth="1" rounded="lg" p="2">
          <HStack gap="2">
            <Avatar size="sm" borderWidth="1" src={`/avatar/${qid}`} name={name} />
            <Stack gap="1">
              <Text fontWeight="medium" size="sm">
                {name}
              </Text>
              <Text size="sm">{text}</Text>
            </Stack>
          </HStack>
        </Box>
      </HStack>
    </Box>
  )
}

const CursorIcon = forwardRef<SVGSVGElement, SVGProps<SVGSVGElement>>((props, ref) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="32"
      height="32"
      viewBox="0 0 16 16"
      ref={ref}
      {...props}
    >
      <path
        fill="currentColor"
        d="M4.002 2.998a1 1 0 0 1 1.6-.8L13.6 8.2c.768.576.36 1.8-.6 1.8H9.053a1 1 0 0 0-.793.39l-2.466 3.215c-.581.758-1.793.347-1.793-.609z"
      />
    </svg>
  )
})
