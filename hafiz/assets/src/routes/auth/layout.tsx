import { Anchor, Center, Container, Image, Paper, Stack, Text, Title, rem } from "@mantine/core"
import { CameraIcon } from "lucide-react"
import { Outlet } from "react-router-dom"
import { Logo } from "~/components/logo"
import "@fontsource-variable/cinzel/wght.css"
import * as styles from "./style.css"

export const AuthLayout = () => {
  return (
    <div className={styles.container}>
      <Cover />
      <Form />
    </div>
  )
}

const Cover = () => {
  return (
    <div className={styles.coverContainer}>
      <div className={styles.coverWrapper}>
        <Image
          className={styles.coverPlaceholder}
          fallbackSrc="data:image/webp;base64,UklGRuIAAABXRUJQVlA4INYAAADwBwCdASpkAEMAP4Wkw12/tjgmtfytE/AwiWUGcA0Eg283KspRwnzbU8OcmUJb0POR9YiNEJ7WRLqmF4Igunj0UYfX/XF4ZLgA/up7xvscvPagV2G3afgWdyEkXJZxOfFBBWb5XdezUJ/0wuC9z5jE5Zw8JqW/7oONQxC6wt36sxC/4UP0F+suaxWSGqmJOBVYAxmM8YL2UVnM3sib6IscHp9s38ak+LsBZEjEG9oY86ryiUYHraTAjD0yC2LokbekrBH8u10JVHndm7bRhxWpfAtfAAAA"
          alt="placeholder"
          aria-hidden="true"
        />
        <Image
          className={styles.coverImage}
          src="/images/bg-books.webp"
          alt="layered books in shadow"
        />
        <Text className={styles.coverSource} c="white" size="sm">
          <CameraIcon
            style={{
              width: rem(16),
              height: rem(16),
              marginInlineEnd: rem(4),
              verticalAlign: "text-top"
            }}
          />
          Photo By{" "}
          <Anchor
            size="sm"
            c="white"
            fw="500"
            href="https://unsplash.com/@rey_7?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
            target="_blank"
          >
            Rey Seven
          </Anchor>{" "}
          on{" "}
          <Anchor
            size="sm"
            c="white"
            fw="500"
            href="https://unsplash.com/photos/brown-books-closeup-photography-_nm_mZ4Cs2I?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash"
            target="_blank"
          >
            Splash
          </Anchor>
        </Text>
        <Text className={styles.coverText} c="white" ff="Cinzel Variable" fw="500">
          Verba volant, sed littera scripta manet.
        </Text>
      </div>
    </div>
  )
}

const Form = () => {
  return (
    <Paper className={styles.formContainer} radius={0}>
      <Stack w="100%" h="100%" gap="xs">
        <Title order={1} ff="Silkscreen" size="h3" lts="-.025em" ta="left">
          <Logo
            style={{
              width: rem(28),
              height: rem(28),
              marginInlineEnd: rem(8),
              verticalAlign: "text-top"
            }}
          />
          Little Red Book
        </Title>
        <Center flex="1">
          <Container size="24rem" w="100%">
            <Outlet />
          </Container>
        </Center>
      </Stack>
    </Paper>
  )
}
