import { ClipboardCheckIcon, ClipboardCopyIcon } from "lucide-react"
import * as Card from "~/components/ui/card"
import * as Clipboard from "~/components/ui/clipboard"
import { FormLabel } from "~/components/ui/form-label"
import { IconButton } from "~/components/ui/icon-button"
import { Input } from "~/components/ui/input"

export const RSSSubscriptionCard = () => {
  return (
    <Card.Root w="full" maxW="sm">
      <Card.Header pb="4">
        <Card.Title>RSS Feed</Card.Title>
        <Card.Description>使用你最爱的 RSS 阅览器来追踪用户的每日动态!</Card.Description>
      </Card.Header>
      <Card.Body>
        <Clipboard.Root value="https://example.com">
          <Clipboard.Label asChild>
            <FormLabel>复制你的订阅链接</FormLabel>
          </Clipboard.Label>
          <Clipboard.Control>
            <Clipboard.Input asChild>
              <Input size="sm" />
            </Clipboard.Input>
            <Clipboard.Trigger asChild>
              <IconButton size="sm" variant="solid">
                <Clipboard.Indicator copied={<ClipboardCheckIcon />}>
                  <ClipboardCopyIcon />
                </Clipboard.Indicator>
              </IconButton>
            </Clipboard.Trigger>
          </Clipboard.Control>
        </Clipboard.Root>
      </Card.Body>
    </Card.Root>
  )
}
