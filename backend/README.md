# Atella Webhook Backend

A Node.js backend service to handle Stripe webhooks and update Firebase user subscriptions.

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
1. Copy `.env.example` to `.env`
2. Fill in your Stripe keys:
   - Get `STRIPE_SECRET_KEY` from Stripe Dashboard → Developers → API Keys
   - `STRIPE_WEBHOOK_SECRET` will be provided after creating webhook (step 4)

### 3. Setup Firebase Admin
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download the JSON file and save it as `firebase-service-account.json` in the backend folder
4. **Important**: Add `firebase-service-account.json` to your `.gitignore`

### 4. Deploy to a Server
You need to deploy this to a publicly accessible server. Options:

#### Option A: Railway (Recommended - Free tier available)
1. Create account at [railway.app](https://railway.app)
2. Connect your GitHub repo
3. Deploy the backend folder
4. Add environment variables in Railway dashboard
5. Get the public URL (e.g., `https://your-app.railway.app`)

#### Option B: Render (Free tier available)
1. Create account at [render.com](https://render.com)
2. Create a new Web Service
3. Connect your GitHub repo, select backend folder
4. Add environment variables
5. Deploy and get public URL

#### Option C: Heroku
1. Create Heroku app
2. Add environment variables
3. Deploy using git or GitHub integration

### 5. Configure Stripe Webhook
1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. Endpoint URL: `https://your-deployed-backend.com/stripe-webhook`
4. Select these events:
   - `customer.subscription.created`
   - `customer.subscription.updated` 
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copy the webhook secret and add it to your `.env` file as `STRIPE_WEBHOOK_SECRET`

### 6. Test the Webhook
1. Start your server: `npm run dev`
2. Use Stripe CLI to forward webhooks for local testing:
   ```bash
   stripe listen --forward-to localhost:3000/stripe-webhook
   ```
3. Or test on your deployed server by making test purchases

## Local Development

```bash
# Install dependencies
npm install

# Start development server with auto-reload
npm run dev

# Start production server
npm start
```

## Testing

### Test with Stripe CLI (Local)
```bash
# Install Stripe CLI
# Then forward webhooks to your local server
stripe listen --forward-to localhost:3000/stripe-webhook
```

### Test Production Webhook
1. Go to Stripe Dashboard → Developers → Webhooks
2. Click on your webhook
3. Click "Send test webhook"
4. Select an event type and send

## File Structure
```
backend/
├── server.js                 # Main server file
├── package.json              # Dependencies
├── .env.example              # Environment variables template
├── firebase-service-account.json  # Firebase admin credentials (gitignored)
└── README.md                 # This file
```

## Security Notes
- Never commit `firebase-service-account.json` to version control
- Always verify webhook signatures
- Use environment variables for all secrets
- Enable CORS only for your domain in production

## Troubleshooting

### Common Issues
1. **Webhook signature verification failed**
   - Check that `STRIPE_WEBHOOK_SECRET` is correct
   - Make sure you're using `express.raw()` middleware

2. **Firebase permission denied**
   - Check that your service account has Firestore write permissions
   - Verify the JSON file is valid

3. **User not found errors**
   - Make sure users have `stripeCustomerId` field set when they subscribe
   - Check that the customer ID in Stripe matches Firebase

### Logs
Check your server logs for detailed error messages:
```bash
# For Railway/Render, check their dashboard logs
# For local development:
npm run dev
```