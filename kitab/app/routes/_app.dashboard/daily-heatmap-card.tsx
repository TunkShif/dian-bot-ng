import { Portal } from "@ark-ui/react"
import { Await, useLoaderData } from "@remix-run/react"
import HeatMap, { type HeatMapValue } from "@uiw/react-heat-map"
import { subDays } from "date-fns"
import { Suspense } from "react"
import { css } from "styled-system/css"
import { Box } from "styled-system/jsx"
import * as Card from "~/components/ui/card"
import * as Tooltip from "~/components/ui/tooltip"
import type { loader as dashboardLoader } from "~/routes/_app.dashboard/route"

export const DailyHeatMapCard = () => {
  const { dailyStatisticsQuery } = useLoaderData<typeof dashboardLoader>()

  return (
    <Card.Root w="full">
      <Card.Header pb="2">
        <Card.Title>入典统计</Card.Title>
      </Card.Header>
      <Card.Body pb="2">
        <Box overflowX="auto">
          <Suspense fallback={<DailyHeatMap data={[]} />}>
            <Await resolve={dailyStatisticsQuery}>
              {(dailyStatistics) => {
                const data = (dailyStatistics.data?.statistics?.dailyThreads ??
                  []) as HeatMapValue[]
                return <DailyHeatMap data={data} />
              }}
            </Await>
          </Suspense>
        </Box>
      </Card.Body>
    </Card.Root>
  )
}

type DailyHeatMapProps = {
  data: HeatMapValue[]
}

const DailyHeatMap = ({ data }: DailyHeatMapProps) => {
  return (
    <HeatMap
      style={{ color: "var(--colors-fg-default)", "--rhm-rect": "var(--colors-bg-emphasized)" }}
      value={data}
      width={620}
      height={180}
      space={4}
      startDate={subDays(new Date(), 30 * 6)}
      rectSize={16}
      rectProps={{ rx: 1.6 }}
      legendCellSize={0}
      rectRender={(props, data) =>
        data.count ? (
          <Tooltip.Root openDelay={200}>
            <Tooltip.Trigger asChild>
              <rect {...props} />
            </Tooltip.Trigger>
            <Portal>
              <Tooltip.Positioner>
                <Tooltip.Content>{`${data.count} 次入典记录 ${data.date}`}</Tooltip.Content>
              </Tooltip.Positioner>
            </Portal>
          </Tooltip.Root>
        ) : (
          <rect {...props} />
        )
      }
    />
  )
}
