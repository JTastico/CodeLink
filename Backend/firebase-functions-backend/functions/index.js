// Importa las bibliotecas necesarias de Firebase Functions y Firebase Admin SDK
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Inicializa el SDK de Admin para interactuar con tu base de datos de Firebase
admin.initializeApp();

// Exporta una función llamada 'sendCommentNotification'
// Esta función se activará cada vez que se cree un nuevo registro
// en el nodo '/notifications/{notificationId}'
exports.sendCommentNotification = functions.database
  .ref("/notifications/{notificationId}")
  .onCreate(async (snapshot) => {
    // 'snapshot' contiene los datos del nuevo registro de notificación
    // que tu app iOS creó
    const notificationData = snapshot.val();

    // Extrae los datos relevantes de la notificación
    const recipientUid = notificationData.recipientUid;
    const senderUsername = notificationData.senderUsername;
    const commentText = notificationData.commentText;
    const publicationId = notificationData.publicationId;

    // --- Paso 1: Obtener el token de FCM del recipiente ---
    const recipientUserSnapshot = await admin
      .database()
      .ref(`/users/${recipientUid}/fcmToken`)
      .once("value");
    const fcmToken = recipientUserSnapshot.val();

    if (!fcmToken) {
      console.log(`No se encontró token FCM para el usuario: ${recipientUid}`);
      return null;
    }

    // --- Paso 2: Construir la carga útil de la notificación ---
    const payload = {
      notification: {
        title: `Nuevo comentario de ${senderUsername}`,
        body: `${commentText.substring(0, 100)}${
          commentText.length > 100 ? "..." : ""
        }`,
        sound: "default",
      },
      data: {
        type: "new_comment",
        publicationId: publicationId,
      },
    };

    // --- Paso 3: Enviar la notificación a través de FCM ---
    try {
      const response = await admin.messaging().sendToDevice(fcmToken, payload);
      console.log("Mensaje enviado exitosamente:", response);

      // Limpia la notificación de la base de datos
      return snapshot.ref.remove();
    } catch (error) {
      console.log("Error al enviar el mensaje:", error);
      return null;
    }
  });
