//
//  NotificationsViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import Foundation
import FirebaseDatabase

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var dbRef: DatabaseReference = Database.database().reference()
    private var notificationsListenerHandle: DatabaseHandle?
    private let currentUserId: String

    init(currentUserId: String) {
        self.currentUserId = currentUserId
        startListeningForNotifications()
    }

    deinit {
        // Asegúrate de remover el observador cuando el ViewModel se destruye
        if let handle = notificationsListenerHandle {
            dbRef.child("notifications").removeObserver(withHandle: handle)
        }
    }

    func startListeningForNotifications() {
        isLoading = true
        errorMessage = nil
        // Limpia las notificaciones anteriores para evitar duplicados al recargar
        notifications = [] 

        // Escucha notificaciones donde el recipientUid coincide con el ID del usuario actual
        notificationsListenerHandle = dbRef.child("notifications")
            .queryOrdered(byChild: "recipientUid")
            .queryEqual(toValue: currentUserId)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                var fetchedNotifications: [Notification] = []

                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if let notificationData = child.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: notificationData)
                            var notification = try JSONDecoder().decode(Notification.self, from: jsonData)
                            notification.id = child.key // Usa el key de Firebase como ID de la notificación
                            fetchedNotifications.append(notification)
                        } catch {
                            print("Error al decodificar la notificación: \(error)")
                            self.errorMessage = "Error al cargar notificaciones."
                        }
                    }
                }
                // Ordena por fecha de creación, las más recientes primero
                self.notifications = fetchedNotifications.sorted(by: { $0.createdAt > $1.createdAt })
                self.isLoading = false
            } withCancel: { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    print("Error al escuchar notificaciones: \(error.localizedDescription)")
                }
            }
    }

    func markNotificationAsRead(notification: Notification) {
        // Solo marca como leída si no lo está ya
        guard !notification.isRead else { return }

        dbRef.child("notifications").child(notification.id).child("isRead").setValue(true) { error, _ in
            if let error = error {
                print("Error al marcar notificación como leída: \(error.localizedDescription)")
            } else {
                // Actualiza la notificación en el array local para que la UI se refresque
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].isRead = true
                }
            }
        }
    }

    func deleteNotification(notification: Notification) {
        dbRef.child("notifications").child(notification.id).removeValue { error, _ in
            if let error = error {
                print("Error al eliminar notificación: \(error.localizedDescription)")
            } else {
                // Elimina la notificación del array local
                self.notifications.removeAll(where: { $0.id == notification.id })
            }
        }
    }
}
