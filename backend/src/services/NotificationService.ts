import * as admin from 'firebase-admin';

import serviceAccountFirebase from '../utils/serviceAccountFirebase';
import { ServiceAccount } from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountFirebase as ServiceAccount),
});

export class NotificationService {
  public static async sendNotification(deviceToken: string, title?: string, body?: string): Promise<void> {
    const message: admin.messaging.Message = {
      notification: {
        title: title || process.env.NOTIFICATION_MSG_TITLE || "",
        body: body || process.env.NOTIFICATION_MSG_BODY || "",
      },
      android: {
        notification: {
          sound: "notification_sound", 
          defaultSound: false,
          channelId:"notification_channel",
          priority: "high"
        },
      },
      token: deviceToken,
    };
    await admin.messaging().send(message);
  }
}

