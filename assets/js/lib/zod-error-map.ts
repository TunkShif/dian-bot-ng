import type { ZodIssue } from "zod";
import * as z from "zod";
import i18n from "i18next";

/**
 * Custom Zod error map that uses i18next for internationalized validation messages.
 *
 * Validation messages are looked up under the `validation.*` namespace in locale files.
 * When no custom message is provided to a Zod validator, this map provides a translated default.
 *
 * Note: This error map is designed to work with Zod v4's error handling system.
 * Custom messages provided to Zod validators (e.g., `.min(5, "custom message")`)
 * will take precedence over this error map.
 */
export const zodErrorMap = (
  issue: ZodIssue,
  ctx: { defaultError: string },
): { message: string } => {
  // Use i18n.t directly - it will use the current language automatically
  const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options);

  switch (issue.code) {
    case "invalid_type":
      if (issue.received === "undefined" || issue.received === "null") {
        return { message: t("validation.required") };
      }
      return {
        message: t("validation.invalid_type", {
          expected: t(`validation.types.${issue.expected}`, { defaultValue: issue.expected }),
          received: t(`validation.types.${issue.received}`, { defaultValue: issue.received }),
        }),
      };

    case "too_small":
      if (issue.type === "string") {
        if (issue.minimum === 1 && !issue.exact) {
          return { message: t("validation.required") };
        }
        if (issue.exact) {
          return {
            message: t("validation.string.length", { length: issue.minimum }),
          };
        }
        return {
          message: t("validation.string.min", { min: issue.minimum }),
        };
      }
      if (issue.type === "number") {
        if (issue.exact) {
          return { message: t("validation.number.exact", { value: issue.minimum }) };
        }
        if (issue.inclusive) {
          return { message: t("validation.number.min", { min: issue.minimum }) };
        }
        return { message: t("validation.number.greater", { min: issue.minimum }) };
      }
      if (issue.type === "array") {
        if (issue.minimum === 1 && !issue.exact) {
          return { message: t("validation.array.nonempty") };
        }
        return { message: t("validation.array.min", { min: issue.minimum }) };
      }
      if (issue.type === "date") {
        return { message: t("validation.date.min") };
      }
      break;

    case "too_big":
      if (issue.type === "string") {
        if (issue.exact) {
          return {
            message: t("validation.string.length", { length: issue.maximum }),
          };
        }
        return {
          message: t("validation.string.max", { max: issue.maximum }),
        };
      }
      if (issue.type === "number") {
        if (issue.exact) {
          return { message: t("validation.number.exact", { value: issue.maximum }) };
        }
        if (issue.inclusive) {
          return { message: t("validation.number.max", { max: issue.maximum }) };
        }
        return { message: t("validation.number.less", { max: issue.maximum }) };
      }
      if (issue.type === "array") {
        return { message: t("validation.array.max", { max: issue.maximum }) };
      }
      if (issue.type === "date") {
        return { message: t("validation.date.max") };
      }
      break;

    case "invalid_string":
      if (issue.validation === "email") {
        return { message: t("validation.string.email") };
      }
      if (issue.validation === "url") {
        return { message: t("validation.string.url") };
      }
      if (issue.validation === "uuid") {
        return { message: t("validation.string.uuid") };
      }
      if (issue.validation === "regex") {
        return { message: t("validation.string.regex") };
      }
      if (issue.validation === "datetime") {
        return { message: t("validation.string.datetime") };
      }
      if (issue.validation === "ip") {
        return { message: t("validation.string.ip") };
      }
      break;

    case "invalid_enum_value":
      return { message: t("validation.invalid_enum") };

    case "unrecognized_keys":
      return { message: t("validation.unrecognized_keys") };

    case "invalid_union":
      return { message: t("validation.invalid_union") };

    case "invalid_literal":
      return { message: t("validation.invalid_literal") };

    case "custom":
      // For custom validations with no message, use the default
      break;
  }

  return { message: ctx.defaultError };
};

/**
 * Helper function to create a Zod schema with i18n-aware validation messages.
 * This is useful for field-specific messages that need to be different from the global defaults.
 *
 * Usage:
 * ```ts
 * const { t } = useTranslation();
 * const schema = createI18nSchema({
 *   password: z.string()
 *     .min(12, t("validation.password.min"))
 *     .max(72, t("validation.password.max")),
 * });
 * ```
 */
export const createI18nSchema = <T extends z.ZodRawShape>(shape: T) => {
  return z.object(shape);
};
