import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import i18n from "i18next";
import * as z from "zod";
import type { SteamPlayerSummaryResponse } from "@/client";
import {
  bindSteamPlayerMemberMutation,
  bindSteamPlayerSelfMutation,
  showGroupQueryKey,
  showSteamPlayerByQqIdOptions,
  showSteamPlayerByQqIdQueryKey,
  showSteamPlayerBySteamIdOptions,
  showSteamPlayerBySteamIdQueryKey,
} from "@/client/@tanstack/react-query.gen";

export type SteamPlayerSummary = NonNullable<SteamPlayerSummaryResponse["data"]["player"]>;

export const STEAM_ID_REGEX = /^7656\d{13}$/;
export const steamIdFieldSchema = z
  .string()
  .min(17, "Steam ID must be 17 characters")
  .max(17, "Steam ID must be 17 characters")
  .regex(STEAM_ID_REGEX, "Must be a valid Steam ID starting with 7656");
export const steamIdSchema = z.object({
  steam_id: steamIdFieldSchema,
});

type HttpErrorLike = {
  status?: number;
};

export const hasHttpStatus = (error: unknown, status: number) =>
  typeof error === "object" && error !== null && "status" in error && (error as HttpErrorLike).status === status;

export const useSteamPlayerLookup = (steamId: string | null) => {
  return useQuery({
    ...showSteamPlayerBySteamIdOptions({
      path: { steam_id: steamId ?? "" },
    }),
    enabled: steamId !== null && STEAM_ID_REGEX.test(steamId),
    retry: (failureCount, error) => {
      if (hasHttpStatus(error, 404)) return false;
      return failureCount < 3;
    },
    select: (data: SteamPlayerSummaryResponse) => data.data.player,
  });
};

export const useBoundSteamPlayer = (qqId: string | null) => {
  return useQuery({
    ...showSteamPlayerByQqIdOptions({
      path: { qq_id: qqId ?? "" },
    }),
    enabled: qqId !== null,
    select: (data: SteamPlayerSummaryResponse) => data.data.player,
  });
};

export const useBindSelfSteamMutation = (qqId: string | null) => {
  const queryClient = useQueryClient();

  return useMutation({
    ...bindSteamPlayerSelfMutation(),
    onSuccess: (_data, variables) => {
      if (qqId) {
        void queryClient.invalidateQueries({
          queryKey: showSteamPlayerByQqIdQueryKey({
            path: { qq_id: qqId },
          }),
        });
      }

      void queryClient.invalidateQueries({
        queryKey: showSteamPlayerBySteamIdQueryKey({
          path: { steam_id: variables.body.steam_id },
        }),
      });
    },
    meta: {
      successTitle: i18n.t("app.settings.steam.bind.successTitle"),
      successMessage: i18n.t("app.settings.steam.bind.successMessage"),
      errorMessage: i18n.t("app.settings.steam.bind.errorMessage"),
    },
  });
};

export const useBindMemberSteamMutation = (groupId: string | null) => {
  const queryClient = useQueryClient();

  return useMutation({
    ...bindSteamPlayerMemberMutation(),
    onSuccess: (_data, variables) => {
      if (groupId) {
        void queryClient.invalidateQueries({
          queryKey: showGroupQueryKey({
            path: { id: groupId },
          }),
        });
      }

      void queryClient.invalidateQueries({
        queryKey: showSteamPlayerByQqIdQueryKey({
          path: { qq_id: variables.path.qq_id },
        }),
      });

      void queryClient.invalidateQueries({
        queryKey: showSteamPlayerBySteamIdQueryKey({
          path: { steam_id: variables.body.steam_id },
        }),
      });
    },
    meta: {
      successTitle: i18n.t("app.settings.steam.bind.successTitle"),
      successMessage: i18n.t("app.settings.steam.bind.successMessage"),
      errorMessage: i18n.t("app.settings.steam.bind.errorMessage"),
    },
  });
};
