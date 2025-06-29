//
//  SearchViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 29/06/25.
//

import Foundation
import FirebaseDatabase
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var dbRef: DatabaseReference = Database.database().reference()
    private var searchCancellable: AnyCancellable?

    init() {
        // Inicializar con algunos usuarios de ejemplo si no hay búsqueda
        // O dejarlo vacío y solo cargar cuando se busque. Por ahora lo dejamos vacío.
    }

    func searchUsers(query: String) {
        isLoading = true
        errorMessage = nil
        users = [] // Limpiar resultados anteriores

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isLoading = false
            return
        }

        // Convertir la consulta a minúsculas para una búsqueda sin distinción de mayúsculas y minúsculas
        let lowercasedQuery = query.lowercased()

        // Firebase Realtime Database no soporta búsquedas complejas (como 'contains' o 'startsWith' de forma nativa en el cliente)
        // en todos los campos sin descargar todos los datos.
        // La forma más eficiente es descargar una lista de usuarios y filtrarla localmente,
        // o si los datos son muy grandes, usar una solución de búsqueda como Algolia o ElasticSearch.
        // Para este ejemplo, supondremos que la cantidad de usuarios es manejable para el filtrado local.

        dbRef.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false
            var fetchedUsers: [User] = []

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let userData = child.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: userData)
                        let user = try JSONDecoder().decode(User.self, from: jsonData)
                        
                        // Filtrar por username o fullName (insensible a mayúsculas/minúsculas)
                        if user.username.lowercased().contains(lowercasedQuery) ||
                           user.fullName.lowercased().contains(lowercasedQuery) {
                            fetchedUsers.append(user)
                        }
                    } catch {
                        print("Error al decodificar usuario: \(error)")
                    }
                }
            }
            // Ordenar los resultados alfabéticamente por nombre de usuario
            self.users = fetchedUsers.sorted(by: { $0.username.lowercased() < $1.username.lowercased() })
        } withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                print("Error al buscar usuarios: \(error.localizedDescription)")
            }
        }
    }
}
