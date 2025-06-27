//
//  CommentsViewModel.swift
//  CodeLink
//
//  Created by Jamil Turpo on 26/06/25.
//


import Foundation
import FirebaseDatabase

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    
    private let publicationService = PublicationService()
    private var commentsListenerHandle: DatabaseHandle?
    private let publicationId: String
    
    init(publicationId: String) {
        self.publicationId = publicationId
        listenForComments()
    }
    
    deinit {
        if let handle = commentsListenerHandle {
            publicationService.removeListener(with: handle)
        }
    }
    
    func listenForComments() {
        commentsListenerHandle = publicationService.listenForComments(for: publicationId) { [weak self] newComments in
            self?.comments = newComments
        }
    }
}
