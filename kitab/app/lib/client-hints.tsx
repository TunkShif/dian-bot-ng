/**
 * This file contains utilities for using client hints for user preference which
 * are needed by the server, but are only known by the browser.
 * @see https://github.com/epicweb-dev/epic-stack/blob/main/app/utils/client-hints.tsx
 */
import { getHintUtils } from "@epic-web/client-hints"
import {
  clientHint as colorSchemeHint,
  subscribeToSchemeChange
} from "@epic-web/client-hints/color-scheme"
import { useRevalidator, useRouteLoaderData } from "@remix-run/react"
import { useEffect } from "react"
import invariant from "tiny-invariant"
import type { loader as rootLoader } from "~/root"

const hintsUtils = getHintUtils({
  theme: colorSchemeHint
})

export const { getHints } = hintsUtils

/**
 * @returns an object with the client hints and their values
 */
export function useHints() {
  const data = useRouteLoaderData<typeof rootLoader>("root")
  invariant(data?.hints, "No hints data fount in root loader.")
  return data.hints
}

/**
 * @returns inline script element that checks for client hints and sets cookies
 * if they are not set then reloads the page if any cookie was set to an
 * inaccurate value.
 */
export function ClientHintCheck({ nonce }: { nonce: string }) {
  const { revalidate } = useRevalidator()
  useEffect(() => subscribeToSchemeChange(() => revalidate()), [revalidate])

  return (
    <script
      nonce={nonce}
      dangerouslySetInnerHTML={{
        __html: hintsUtils.getClientHintCheckScript()
      }}
    />
  )
}
