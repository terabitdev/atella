const APPSFLYER_S2S_URL = 'https://api3.appsflyer.com/inappevent';

export interface AppsFlyerPurchaseEventParams {
  appsflyerId: string;
  platform: 'android' | 'ios';
  customerUserId: string;
  contentId: string;
  revenue: number;
  currency: string;
}

function getAppIdForPlatform(platform: 'android' | 'ios'): string | null {
  const androidAppId = process.env.APPSFLYER_ANDROID_APP_ID;
  const iosAppId = process.env.APPSFLYER_IOS_APP_ID;

  if (platform === 'ios') {
    return iosAppId || null;
  }
  return androidAppId || null;
}

/**
 * Sends an af_purchase event to AppsFlyer via the S2S API.
 * Used for website subscription payments that occur outside the mobile app.
 * Failures are logged but never thrown — analytics must not break webhooks.
 */
export async function sendAppsFlyerPurchaseEvent(
  params: AppsFlyerPurchaseEventParams,
): Promise<void> {
  const s2sKey = process.env.APPSFLYER_S2S_KEY;

  if (!s2sKey) {
    console.log('⚠️ AppsFlyer S2S: APPSFLYER_S2S_KEY not configured, skipping af_purchase');
    return;
  }

  const appId = getAppIdForPlatform(params.platform);
  if (!appId) {
    const envName =
      params.platform === 'ios'
        ? 'APPSFLYER_IOS_APP_ID'
        : 'APPSFLYER_ANDROID_APP_ID';
    console.log(`⚠️ AppsFlyer S2S: ${envName} not configured, skipping af_purchase`);
    return;
  }

  const url = `${APPSFLYER_S2S_URL}/${appId}`;

  const eventValue = JSON.stringify({
    af_content_id: params.contentId,
    af_revenue: params.revenue.toFixed(2),
    af_currency: params.currency,
  });

  const body = {
    appsflyer_id: params.appsflyerId,
    customer_user_id: params.customerUserId,
    eventName: 'af_purchase',
    eventValue,
    eventCurrency: params.currency,
  };

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        authentication: s2sKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const responseText = await response.text();

    if (!response.ok) {
      console.error(
        `❌ AppsFlyer S2S: af_purchase failed (${response.status}): ${responseText}`,
      );
      return;
    }

    console.log(
      `✅ AppsFlyer S2S: af_purchase sent (${params.contentId}, ${params.revenue} ${params.currency})`,
    );
  } catch (error) {
    console.error('❌ AppsFlyer S2S: request error:', error);
  }
}
