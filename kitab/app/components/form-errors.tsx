import { unique } from "radash"
import { Stack, type StackProps } from "styled-system/jsx"
import { Text } from "~/components/ui/text"

export type FormErrorsProps = {
  errors: string[] | undefined
} & StackProps

export const FormErrors = (props: FormErrorsProps) => {
  if (!props.errors) return null

  const errors = unique(props.errors)

  return (
    <Stack>
      {errors.map((error) => (
        <Text key={error} size="sm" color="accent.emphasized">
          * {error}
        </Text>
      ))}
    </Stack>
  )
}
