import { admin, db } from './admin';

function isDeadTokenError(code?: string) {
  return code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-argument';
}

/// Sends an FCM push to every device registered for `recipientUid` (see
/// `users/{uid}.fcmTokens`, written by PushNotificationService on the
/// client). The `notification` block is what makes FCM auto-display a
/// system-tray notification while the app is backgrounded or killed, with
/// no extra client code. Prunes any token FCM reports as dead.
export async function sendPushToUser(
  recipientUid: string,
  title: string,
  body: string,
  data: Record<string, string> = {}
) {
  const userSnap = await db.collection('users').doc(recipientUid).get();
  const tokens: string[] = userSnap.data()?.fcmTokens ?? [];
  if (tokens.length === 0) return;

  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data,
    });

    const deadTokens = response.responses
      .map((r, i) => (!r.success && isDeadTokenError(r.error?.code) ? tokens[i] : null))
      .filter((t): t is string => t !== null);

    if (deadTokens.length > 0) {
      await db.collection('users').doc(recipientUid).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...deadTokens),
      });
    }
  } catch (e) {
    console.error(`⚠️ sendPushToUser(${recipientUid}) failed:`, e);
  }
}
