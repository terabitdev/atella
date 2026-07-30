import * as admin from 'firebase-admin';
import Stripe from 'stripe';

// Upgraded to 2nd Gen Functions - 2026-02-10
admin.initializeApp();

export { admin };
export const db = admin.firestore();

const stripeSecretKey = process.env.STRIPE_SECRET_KEY || '';

export const stripe = new Stripe(stripeSecretKey, {
  apiVersion: '2023-10-16',
});

export const FUNCTIONS_REGION = 'us-central1';
export const SERVICE_ACCOUNT = 'atella-87@atelia-123.iam.gserviceaccount.com';
