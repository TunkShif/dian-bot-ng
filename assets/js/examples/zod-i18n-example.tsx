/**
 * Example: Using Zod with i18n in DianBot
 *
 * This file demonstrates how to use Zod validation with internationalized error messages.
 * The global error map is already configured in i18next.ts, so most validations will
 * automatically use translated messages.
 */

import { useForm } from "@tanstack/react-form";
import { useTranslation } from "react-i18next";
import * as z from "zod";

// Example 1: Using global error map (automatic i18n)
// The .min(1) will automatically show "Required" in the current language
const simpleSchema = z.object({
  name: z.string().min(1), // Uses global error map: "validation.required"
  email: z.string().email(), // Uses global error map: "validation.string.email"
  age: z.number().min(0).max(150), // Uses global error map: "validation.number.min", "validation.number.max"
});

// Example 2: Custom field-specific messages
// Use this when you need different messages for the same validation type
const passwordSchema = z.object({
  password: z
    .string()
    .min(8, "validation.password.min") // Custom message key
    .max(100, "validation.password.max"), // Custom message key
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "validation.password.match",
  path: ["confirmPassword"],
});

// Example 3: Using in a React component
export const ExampleForm = () => {
  const { t } = useTranslation();

  // Create schema with translated messages
  const formSchema = z.object({
    username: z
      .string()
      .min(3, t("validation.username.min"))
      .max(20, t("validation.username.max")),
    email: z.string().email(), // Uses global error map
    website: z.string().url().optional(), // Uses global error map
  });

  const form = useForm({
    defaultValues: {
      username: "",
      email: "",
      website: "",
    },
    validators: {
      onSubmit: formSchema,
    },
    onSubmit: async ({ value }) => {
      console.log("Form submitted:", value);
    },
  });

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        form.handleSubmit();
      }}
    >
      <div>
        <label htmlFor="username">{t("form.username.label")}</label>
        <form.Field name="username">
          {(field) => (
            <>
              <input
                id="username"
                value={field.state.value}
                onChange={(e) => field.handleChange(e.target.value)}
              />
              {field.state.meta.errors.map((error) => (
                <p key={error?.message} className="error">
                  {error?.message}
                </p>
              ))}
            </>
          )}
        </form.Field>
      </div>

      <div>
        <label htmlFor="email">{t("form.email.label")}</label>
        <form.Field name="email">
          {(field) => (
            <>
              <input
                id="email"
                type="email"
                value={field.state.value}
                onChange={(e) => field.handleChange(e.target.value)}
              />
              {field.state.meta.errors.map((error) => (
                <p key={error?.message} className="error">
                  {error?.message}
                </p>
              ))}
            </>
          )}
        </form.Field>
      </div>

      <div>
        <label htmlFor="website">{t("form.website.label")}</label>
        <form.Field name="website">
          {(field) => (
            <>
              <input
                id="website"
                type="url"
                value={field.state.value}
                onChange={(e) => field.handleChange(e.target.value)}
              />
              {field.state.meta.errors.map((error) => (
                <p key={error?.message} className="error">
                  {error?.message}
                </p>
              ))}
            </>
          )}
        </form.Field>
      </div>

      <button type="submit">{t("form.submit")}</button>
    </form>
  );
};

/**
 * Translation keys used in validation messages:
 *
 * validation.required - "This field is required."
 * validation.string.email - "Invalid email address."
 * validation.string.url - "Invalid URL."
 * validation.string.min - "Must be at least {{min}} characters."
 * validation.string.max - "Must be at most {{max}} characters."
 * validation.number.min - "Must be at least {{min}}."
 * validation.number.max - "Must be at most {{max}}."
 *
 * Custom keys (add to your translation files):
 * validation.username.min - "Username must be at least 3 characters."
 * validation.username.max - "Username must be at most 20 characters."
 * validation.password.min - "Password must be at least 8 characters."
 * validation.password.max - "Password must be at most 100 characters."
 * validation.password.match - "Passwords must match."
 */