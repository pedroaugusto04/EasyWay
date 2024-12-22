import * as admin from 'firebase-admin';

const serviceAccount = require('../../vanAppFirebase.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export class NotificationService {

  public static async sendNotification(deviceToken: string): Promise<void> {
    const message: admin.messaging.Message = {
      notification: {
        title: process.env.NOTIFICATION_MSG_TITLE || "",
        body: process.env.NOTIFICATION_MSG_BODY || "",
      },
      token: deviceToken,
    };
    await admin.messaging().send(message);
  }
}
