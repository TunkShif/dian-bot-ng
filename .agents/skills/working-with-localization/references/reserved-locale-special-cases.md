# Reserved Locale Special Cases

Use this reference before treating English-looking locale values as missing translations. These values are intentional product, domain, or locale-specific labels.

## Intentional English Labels

| Key | Locales | Reserved value | Reason |
| --- | --- | --- | --- |
| `app.nav.aiAssistant` | `zh`, `yue` | `AI Intelligence` | Product feature name kept in English for Chinese and Cantonese UI. Do not replace during fallback cleanup unless the product naming decision changes. |

## Valid Same-As-English Values

Some translated values can match English because the target language uses the same word or spelling. Do not flag these as fallback without checking the locale context.

| Key | Locale | Value | Reason |
| --- | --- | --- | --- |
| `app.header.title` | `fr` | `Documents` | Valid French label. |
| `app.userMenu.notifications` | `fr` | `Notifications` | Valid French label. |

## Product Literals

These values are product names, identifiers, examples, or fixed protocol/domain text. They may be identical across all locales.

| Key | Reason |
| --- | --- |
| `auth.login.brandName` | Product/brand text. |
| `app.brandName` | Product/brand text. |
| `auth.login.emailInput.placeholder` | Example QQ number input. |
| `auth.login.emailInput.domain` | Fixed email domain suffix. |
