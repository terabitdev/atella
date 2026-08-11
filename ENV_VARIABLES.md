# Environment Variables Reference

This lists the **names only** of every environment variable used by the app — no values, for security. There are two separate `.env` files in the project, each read by a different part of the app.

## `.env` (project root — used by the Flutter app itself)

| Variable | What it's for |
|---|---|
| `OPENAI_API_KEY` | AI design/tech pack generation |
| `YOUR_WEB_CLIENT_ID_HERE` | Google Sign-In |
| `PublishableKey` | Stripe payments (public key, safe to be in the app) |
| `StripeSecretKey` | Stripe payments (legacy — used by the old subscription flow only) |
| `STRIPE_WEBHOOK_SECRET` | Verifying Stripe payment/subscription notifications |
| `EMAILJS_SERVICE_ID` | Old email-to-manufacturer feature (being phased out) |
| `EMAILJS_TEMPLATE_ID` | Old email-to-manufacturer feature (being phased out) |
| `EMAILJS_PUBLIC_KEY` | Old email-to-manufacturer feature (being phased out) |
| `PORT` | Local development only |
| `NODE_ENV` | Environment flag (development/production) |
| `POSTHOG_API_KEY` | Analytics tracking |
| `POSTHOG_HOST` | Analytics tracking |

## `functions/.env` (used by the backend Cloud Functions)

| Variable | What it's for |
|---|---|
| `OPENAI_API_KEY` | AI design/tech pack generation |
| `YOUR_WEB_CLIENT_ID_HERE` | Google Sign-In |
| `PUBLISHABLE_KEY` | Stripe payments (public key) |
| `STRIPE_SECRET_KEY` | Stripe payments (private key, backend only) |
| `STRIPE_WEBHOOK_SECRET` | Verifying subscription-related Stripe notifications |
| `EMAILJS_SERVICE_ID` | Old email-to-manufacturer feature (being phased out) |
| `EMAILJS_TEMPLATE_ID` | Old email-to-manufacturer feature (being phased out) |
| `EMAILJS_PUBLIC_KEY` | Old email-to-manufacturer feature (being phased out) |
| `NODE_ENV` | Environment flag (development/production) |
| `ADMIN_BOOTSTRAP_SECRET` | One-time secret used to create the very first admin account |
| `STRIPE_CONNECT_WEBHOOK_SECRET` | Verifying "manufacturer finished payout setup" notifications from Stripe |
| `STRIPE_ORDERS_WEBHOOK_SECRET` | Verifying "order payment received" notifications from Stripe |

## Notes

- Several variables (Stripe keys, webhook secrets) currently have both a **live** value and a **test** value saved side by side in the files, with the unused one commented out (`#`) — this makes it easy to switch between real payments and safe testing by commenting/uncommenting a line.
- Both `.env` files are excluded from version control (`.gitignore`) and are never shared or committed — this document only records variable *names* for reference, never the actual secret values.
