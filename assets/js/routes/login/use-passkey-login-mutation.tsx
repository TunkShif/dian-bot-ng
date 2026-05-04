import { type UseMutationOptions, useMutation } from "@tanstack/react-query";
import { beginPasskeyLogin, completePasskeyLogin } from "@/client";
import { fromBase64Url, toBase64Url } from "@/lib/utils";

const loginWithPasskey = async () => {
  const { data: beginResponse } = await beginPasskeyLogin({ throwOnError: true });

  const opts = beginResponse.data.options;
  const credential = await navigator.credentials.get({
    publicKey: {
      ...opts,
      challenge: fromBase64Url(opts.challenge),
    } as PublicKeyCredentialRequestOptions,
  });

  if (!credential) {
    throw new Error("Passkey sign-in was cancelled");
  }

  const pkCredential = credential as PublicKeyCredential;
  const response = pkCredential.response as AuthenticatorAssertionResponse;

  await completePasskeyLogin({
    throwOnError: true,
    body: {
      rawId: pkCredential.id,
      response: {
        clientDataJSON: toBase64Url(response.clientDataJSON),
        authenticatorData: toBase64Url(response.authenticatorData),
        signature: toBase64Url(response.signature),
        userHandle: response.userHandle ? toBase64Url(response.userHandle) : null,
      },
    },
  });
};

export const usePasskeyLoginMutation = (options?: Omit<UseMutationOptions<unknown, Error, void>, "mutationFn">) =>
  useMutation({ mutationFn: loginWithPasskey, ...options });
