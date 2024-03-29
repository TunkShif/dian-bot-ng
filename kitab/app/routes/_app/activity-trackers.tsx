import { Portal } from "@ark-ui/react"
import { autoPlacement, shift, useFloating } from "@floating-ui/react-dom"
import { Await, useLocation } from "@remix-run/react"
import { addHours, intlFormatDistance } from "date-fns"
import { AnimatePresence, motion } from "framer-motion"
import type { UserActivity } from "gql/graphql"
import { atom, useAtomValue } from "jotai"
import { type SVGProps, Suspense, forwardRef, useMemo } from "react"
import { Box, HStack } from "styled-system/jsx"
import { Avatar } from "~/components/ui/avatar"
import { Icon } from "~/components/ui/icon"
import { Text } from "~/components/ui/text"
import {
  type OnlineUserActivity,
  onlineUserActivitiesAtom,
  showHistoryActivityAtom,
  showOnlineActivityAtom
} from "~/lib/trackers"
import { useAppLoaderData } from "~/routes/_app/route"

const dimensionAtom = atom({
  init: false,
  width: typeof window !== "undefined" ? window.innerWidth : 0,
  height: typeof window !== "undefined" ? window.innerHeight : 0
})
dimensionAtom.onMount = (setAtom) => {
  const setup = () =>
    setAtom({
      init: true,
      width: window.innerWidth,
      height: window.innerHeight
    })

  setup()
  window.addEventListener("resize", setup)
  return () => window.removeEventListener("resize", setup)
}

export const ActivityTrackers = () => {
  return (
    <Portal>
      <Box position="relative" zIndex="popover">
        <HistoryTrackers />
        <RealtimeTrackers />
      </Box>
    </Portal>
  )
}

const HistoryTrackers = () => {
  const { userActivitiesQuery } = useAppLoaderData()
  return (
    <Suspense>
      <Await resolve={userActivitiesQuery}>
        {(userActivities) => (
          <HistoryTrackerList
            activities={
              userActivities.data?.userActivities.edges.map(({ node }) => node as UserActivity) ??
              []
            }
          />
        )}
      </Await>
    </Suspense>
  )
}

const HistoryTrackerList = ({ activities }: { activities: UserActivity[] }) => {
  const showHistoryActivity = useAtomValue(showHistoryActivityAtom)
  if (!showHistoryActivity) return null

  return (
    <ul>
      {activities.map((activity) => (
        <HistoryIndicator key={activity.id} activity={activity} />
      ))}
    </ul>
  )
}

const HistoryIndicator = ({ activity }: { activity: UserActivity }) => {
  const { mouseX, mouseY, location, offlineAt, user } = activity

  const { shouldRender, refs, floatingStyles } = useIndicator({ mouseX, mouseY, location })

  const now = new Date()
  const ago = addHours(new Date(offlineAt), 8)
  const distance = intlFormatDistance(ago, now, { locale: "zh-Hans-CN" })

  return (
    <AnimatePresence>
      {shouldRender && (
        <motion.li
          initial={{ opacity: 0 }}
          animate={{
            opacity: 1,
            transition: {
              delay: 1,
              duration: 2
            }
          }}
          exit={{ opacity: 0 }}
        >
          <Box ref={refs.setFloating} style={floatingStyles}>
            <Box
              position="relative"
              bg="bg.subtle/45"
              backdropFilter="auto"
              backdropBlur="sm"
              rounded="full"
              p="1"
              shadow="lg"
            >
              <HStack gap="2">
                <Avatar size="sm" borderWidth="1" src={`/avatar/${user.qid}`} name={user.name} />
                <Box textWrap="nowrap" pr="1">
                  <Text dir="rtl" size="sm" fontWeight="semibold" as="span">
                    {user.name}
                  </Text>{" "}
                  <Text size="sm" as="span">
                    {distance}
                  </Text>
                  <Text size="sm" as="span">
                    来过
                  </Text>
                </Box>
              </HStack>
            </Box>
          </Box>
        </motion.li>
      )}
    </AnimatePresence>
  )
}

const RealtimeTrackers = () => {
  const activities = useAtomValue(onlineUserActivitiesAtom)
  return <RealtimeTrackerList activities={Object.values(activities)} />
}

const RealtimeTrackerList = ({ activities }: { activities: OnlineUserActivity[] }) => {
  const showOnlineActivity = useAtomValue(showOnlineActivityAtom)
  if (!showOnlineActivity) return null
  return (
    <ul>
      {activities.map((activity) => (
        <RealtimeIndicator key={activity.id} activity={activity} />
      ))}
    </ul>
  )
}

const RealtimeIndicator = ({ activity }: { activity: OnlineUserActivity }) => {
  const {
    currentUser: { id: myself }
  } = useAppLoaderData()

  const { mouseX, mouseY, location, user } = activity

  const { shouldRender, refs, floatingStyles } = useIndicator({ mouseX, mouseY, location })

  const shouldIgnore = activity.id === myself || !shouldRender

  return (
    <AnimatePresence>
      {!shouldIgnore && (
        <motion.li
          initial={{ opacity: 0 }}
          animate={{
            opacity: 1,
            transition: {
              delay: 1,
              duration: 2
            }
          }}
          exit={{ opacity: 0 }}
        >
          <Box
            ref={refs.setFloating}
            transition="transform"
            transitionDuration="500ms"
            transitionTimingFunction="ease-in-out"
            style={floatingStyles}
          >
            <Box
              position="relative"
              bg="bg.subtle/45"
              backdropFilter="auto"
              backdropBlur="sm"
              rounded="full"
              px="4"
              py="2"
              shadow="lg"
            >
              <Icon position="absolute" left="-2" top="-2" size="md" color="accent.default">
                <CursorIcon />
              </Icon>
              <Text size="sm" fontWeight="semibold">
                {user.name}
              </Text>
            </Box>
          </Box>
        </motion.li>
      )}
    </AnimatePresence>
  )
}

const useIndicator = ({
  location,
  mouseX,
  mouseY
}: { location: string; mouseX: number; mouseY: number }) => {
  const atCurrentPage = useLocation().pathname === location

  const dimension = useAtomValue(dimensionAtom)
  const virtualElement = useMemo(
    () => ({
      getBoundingClientRect() {
        const x = (mouseX / 100) * dimension.width
        const y = (mouseY / 100) * dimension.height
        return {
          width: 0,
          height: 0,
          x,
          y,
          left: x,
          right: x,
          top: y,
          bottom: y
        }
      }
    }),
    [mouseX, mouseY, dimension.width, dimension.height]
  )

  const { refs, floatingStyles } = useFloating({
    placement: "right",
    strategy: "fixed",
    middleware: [shift(), autoPlacement()],
    elements: {
      reference: virtualElement
    }
  })

  const shouldRender = atCurrentPage && dimension.init

  return { shouldRender, refs, floatingStyles }
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
      <title>cursor</title>
      <path
        fill="currentColor"
        d="M4.002 2.998a1 1 0 0 1 1.6-.8L13.6 8.2c.768.576.36 1.8-.6 1.8H9.053a1 1 0 0 0-.793.39l-2.466 3.215c-.581.758-1.793.347-1.793-.609z"
      />
    </svg>
  )
})
