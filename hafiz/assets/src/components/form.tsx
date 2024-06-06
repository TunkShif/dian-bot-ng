import { unique } from "radash"
import { useMemo } from "react"
import { Stack, type StackProps } from "styled-system/jsx"
import { Text } from "~/components/ui/text"

export type FormErrorsProps = {
  errors: string[] | undefined
} & StackProps

export const FormErrors = ({ errors, ...props }: FormErrorsProps) => {
  if (!errors) return null

  const messages = useMemo(() => unique(errors), [errors])
  return (
    <Stack {...props}>
      {messages.map((message) => (
        <Text key={message} size="sm" color="accent.emphasized">
          * {message}
        </Text>
      ))}
    </Stack>
  )
}
