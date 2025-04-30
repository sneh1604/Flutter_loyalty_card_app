const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onCardCreated = functions.firestore
    .document('users/{userId}/cards/{cardId}')
    .onCreate(async (snap, context) => {
      const cardData = snap.data();
      const userId = context.params.userId;

      try {
        const userDoc = await admin.firestore()
            .collection('users')
            .doc(userId)
            .get();
        
        const fcmToken = userDoc.data()?.fcmToken;
        
        if (fcmToken) {
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: 'New Card Added',
              body: `Your card "${cardData.title}" has been added successfully!`
            }
          });
        }
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });
