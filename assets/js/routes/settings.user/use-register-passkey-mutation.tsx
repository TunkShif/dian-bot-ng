import { useMutation, useQueryClient } from "@tanstack/react-query";
import { beginPasskeyRegistration, completePasskeyRegistration } from "@/client";
import { listPasskeysQueryKey } from "@/client/@tanstack/react-query.gen";
import { fromBase64Url, toBase64Url } from "@/lib/utils";

const registerPasskey = async (label: string) => {
  const { data: beginResponse } = await beginPasskeyRegistration({ throwOnError: true });

  const opts = beginResponse.data.options;
  const credential = await navigator.credentials.create({
    publicKey: {
      ...opts,
      challenge: fromBase64Url(opts.challenge),
      user: { ...opts.user, id: fromBase64Url(opts.user.id) },
    } as PublicKeyCredentialCreationOptions,
  });

  if (!credential) {
    throw new Error("Failed to create passkey");
  }

  const pkCredential = credential as PublicKeyCredential;
  const response = pkCredential.response as AuthenticatorAttestationResponse;

  await completePasskeyRegistration({
    throwOnError: true,
    body: {
      label,
      rawId: pkCredential.id,
      response: {
        clientDataJSON: toBase64Url(response.clientDataJSON),
        attestationObject: toBase64Url(response.attestationObject),
      },
    },
  });
};

export const useRegisterPasskeyMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: registerPasskey,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: listPasskeysQueryKey() });
    },
  });
};
