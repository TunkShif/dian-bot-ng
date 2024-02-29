import { InfoIcon } from "lucide-react"
import { VStack } from "styled-system/jsx"
import * as Alert from "~/components/ui/alert"

export const PinnedMessageList = () => {
  return (
    <VStack w="full">
      <Alert.Root>
        <Alert.Icon asChild>
          <InfoIcon />
        </Alert.Icon>
        <Alert.Content>
          <Alert.Title>站点迁移升级通知</Alert.Title>
          <Alert.Description>
            本站正在完成全新版本的开发中，旧数据将陆续迁移导入。请耐心等待~
          </Alert.Description>
        </Alert.Content>
      </Alert.Root>
    </VStack>
  )
}
