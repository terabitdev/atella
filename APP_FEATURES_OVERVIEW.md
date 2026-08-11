# Atella — App Features Overview

A plain-language summary of everything the Atella app does today. This is not technical documentation — it's a walkthrough of what a user can actually do in the app, feature by feature. (For the supplier marketplace specifically, see `SUPPLIER_MARKETPLACE_OVERVIEW.md`.)

## What Atella is, in one sentence

Atella helps independent fashion/apparel brands turn an idea for a garment into a professional, production-ready "tech pack" — the technical specification document a factory needs to actually manufacture it — using AI to do the design and documentation work a brand would otherwise need a designer or pattern-maker for.

## 1. Account & onboarding

- **Sign up** with email, Google, or Apple.
- A short **verification step** confirms the new account.
- A guided **onboarding flow** asks about the user's brand (name, what they make), their goals, their production preferences, and their experience level, and gives a quick intro to the app's features — so the experience can be tailored to who's using it (a total beginner vs. an experienced brand owner).

## 2. Creating a design (the core feature)

This is the heart of the app: a guided, conversational process that turns a rough idea into a finished garment design, without needing any design software or skill.

- **Creative Brief** — the app asks the user a series of questions: what type of garment, what style, who it's for, what occasion it's for, any inspiration images, preferred colors/patterns, and fabric/material. Answers are picked from quick tap options or typed in.
- **Refining the Concept** — a second round of questions narrows things down further: fit, any special construction details, seasonal needs, and target price point.
- **Final Details** — a last round confirms the season, budget tier, and any brand values that matter (e.g. organic fabric, upcycled materials, made locally, UV protection), plus an open text box for anything else.
- **AI design generation** — using all of the answers, the app generates visual concepts of the garment. The user reviews them and can ask for changes until they're happy, then picks their favorite.

## 3. Tech pack generation

Once a design is finalized, the user can generate a full **tech pack** — the detailed technical document a garment factory needs to actually produce the item (measurements, construction notes, materials, etc.). This can be exported as a branded PDF, a plain PDF, or a Word document, ready to send to a manufacturer.

## 4. Home & navigation

The app is organized around four main tabs:
- **Home** — a dashboard showing recent designs and collections, with a button to start a new project.
- **Create** — jumps straight into starting a new design.
- **Favourite** — a quick-access list of designs the user has favorited.
- **Settings** — account settings, subscription management, and (for the newer marketplace features) messages and orders.

## 5. Managing designs

- **My Designs** — every design the user has ever created, browsable at any time.
- **Collections** — designs can be grouped into named collections (e.g. by season or product line) to stay organized.
- From any design, the user can **edit** it, **download** its images to their phone, or **share** it, and mark it as a **favorite**.

## 6. Subscription plans

Atella runs on a monthly (or discounted yearly) subscription with four tiers:
- **Free** — a small number of AI design generations per month; no tech pack generation, PDF export, or manufacturer access.
- **Starter**, **Pro**, and **Studio** — increasingly higher monthly design allowances, and unlock tech pack generation, full PDF export, 3D visualization, and manufacturer access.

Usage is tracked against the plan's monthly limit, with a warning shown as the user approaches it. Plan details, upgrades, and cancellation are managed from a dedicated subscription section.

## 7. Supplier marketplace (manufacturing partners)

Covered in full in `SUPPLIER_MARKETPLACE_OVERVIEW.md`, but in short: users can browse invited manufacturing partners ("suppliers"), send them a finished tech pack, message them directly in-app, and pay for a priced sample order — all without leaving Atella, with tracking once it ships.

## 8. Legacy manufacturer directory

An older, simpler feature — a static, browsable list of manufacturers shown alongside a finished tech pack, with no messaging or ordering. This existed before the supplier marketplace was built and has recently been disconnected from the app's navigation (its underlying code is still present but no longer reachable), since the supplier marketplace now covers this need properly.

## 9. Account management

From Settings, users can:
- Edit their **personal information**.
- View and manage their **subscription**.
- Read the app's **Terms & Privacy**.
- **Log out**.
- **Permanently delete their account** (with a password-confirmation step, to prevent accidental deletion).

## 10. Behind-the-scenes features (not directly visible, but shape the experience)

- **Multi-language support** — the app (including the design questionnaires) supports multiple languages, currently English and French.
- **Deep links** — links (like a supplier invite) can open the app directly to the right screen instead of just the app's home page.
- **Usage analytics** — anonymized in-app behavior is tracked to help improve the product over time.
- **Content translation** — manufacturer-related content is automatically translated for non-English users.
