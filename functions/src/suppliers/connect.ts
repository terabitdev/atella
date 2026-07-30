import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import { db, stripe, FUNCTIONS_REGION, SERVICE_ACCOUNT } from '../lib/admin';
import { requireSupplier } from '../lib/roles';

function supplierIdFromClaims(request: any): string {
  const supplierId = request.auth?.token?.supplierId;
  if (!supplierId || typeof supplierId !== 'string') {
    throw new HttpsError('failed-precondition', 'No supplier account linked to this session.');
  }
  return supplierId;
}

// Creates (or returns the existing) Stripe Express connected account for the
// calling supplier. Idempotent — safe to call every time onboarding starts.
async function ensureConnectAccount(supplierId: string, email: string | undefined): Promise<string> {
  const supplierRef = db.collection('suppliers').doc(supplierId);
  const supplierSnap = await supplierRef.get();
  if (!supplierSnap.exists) {
    throw new HttpsError('not-found', 'Supplier profile not found.');
  }

  const existingAccountId = supplierSnap.data()?.stripeConnectAccountId;
  if (existingAccountId) {
    return existingAccountId;
  }

  const account = await stripe.accounts.create({
    type: 'express',
    email,
    capabilities: {
      transfers: { requested: true },
      card_payments: { requested: true },
    },
  });

  await supplierRef.update({
    stripeConnectAccountId: account.id,
    onboardingStatus: 'in_progress',
  });

  return account.id;
}

export const createConnectAccount = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireSupplier(request);
    const supplierId = supplierIdFromClaims(request);
    const accountId = await ensureConnectAccount(supplierId, request.auth?.token?.email);
    return { accountId };
  }
);

export const createConnectOnboardingLink = onCall(
  { region: FUNCTIONS_REGION },
  async (request) => {
    requireSupplier(request);
    const supplierId = supplierIdFromClaims(request);
    const accountId = await ensureConnectAccount(supplierId, request.auth?.token?.email);

    const baseUrl = `https://${FUNCTIONS_REGION}-atelia-123.cloudfunctions.net`;
    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/stripeConnectRefreshPage`,
      return_url: `${baseUrl}/stripeConnectReturnPage`,
      type: 'account_onboarding',
    });

    return { url: accountLink.url };
  }
);

function htmlPage(message: string): string {
  return `<!doctype html><html><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Atella</title></head>
  <body style="font-family: -apple-system, sans-serif; text-align: center; padding: 60px 20px;">
    <h2>${message}</h2>
    <p>You can close this window and return to the Atella app.</p>
  </body></html>`;
}

// Stripe requires real https:// URLs for onboarding redirects. There's no
// web app to host these, so these two functions just serve a static
// "return to the app" message — the Flutter app picks up the real status
// change live via a Firestore listener, not via this redirect.
export const stripeConnectReturnPage = onRequest(
  { serviceAccount: SERVICE_ACCOUNT, cors: true, region: FUNCTIONS_REGION },
  (req, res) => {
    res.set('Content-Type', 'text/html');
    res.send(htmlPage("You're all set."));
  }
);

export const stripeConnectRefreshPage = onRequest(
  { serviceAccount: SERVICE_ACCOUNT, cors: true, region: FUNCTIONS_REGION },
  (req, res) => {
    res.set('Content-Type', 'text/html');
    res.send(htmlPage('This onboarding link expired — please return to the app and try again.'));
  }
);

// Separate endpoint + signing secret from the subscriptions webhook —
// Connect events (account.updated) are configured as their own Stripe
// Dashboard webhook endpoint.
const stripeConnectWebhookSecret = process.env.STRIPE_CONNECT_WEBHOOK_SECRET || '';

export const stripeConnectWebhook = onRequest(
  { serviceAccount: SERVICE_ACCOUNT, cors: true, region: FUNCTIONS_REGION },
  async (req, res) => {
    const sig = req.headers['stripe-signature'] as string;
    let event;

    try {
      const rawBody = (req as any).rawBody;
      if (!rawBody) {
        res.status(400).send('Webhook Error: raw body not available');
        return;
      }
      event = stripe.webhooks.constructEvent(rawBody, sig, stripeConnectWebhookSecret);
    } catch (err: any) {
      console.error('❌ CONNECT WEBHOOK: Signature verification failed.', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    try {
      if (event.type === 'account.updated') {
        const account = event.data.object as any;
        const snap = await db
          .collection('suppliers')
          .where('stripeConnectAccountId', '==', account.id)
          .limit(1)
          .get();

        if (!snap.empty) {
          const detailsSubmitted = !!account.details_submitted;
          const payoutsEnabled = !!account.payouts_enabled;
          await snap.docs[0].ref.update({
            detailsSubmitted,
            payoutsEnabled,
            onboardingStatus: payoutsEnabled ? 'complete' : detailsSubmitted ? 'in_progress' : 'not_started',
          });
          console.log(`✅ CONNECT WEBHOOK: supplier ${snap.docs[0].id} payoutsEnabled=${payoutsEnabled}`);
        } else {
          console.log(`🤷 CONNECT WEBHOOK: no supplier found for account ${account.id}`);
        }
      }
      res.json({ received: true });
    } catch (error) {
      console.error('❌ CONNECT WEBHOOK: processing failed', error);
      res.status(500).send('Webhook processing failed');
    }
  }
);
