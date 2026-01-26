//
//  UpdateView.swift
//  Golympians
//
//  Created by Bernard Scott on 1/26/26.
//

import SwiftUI
import FirebaseFirestore

struct UpdateView: View {
    @Binding var showUpdateView: Bool
    
    var body: some View {
        Spacer()
        
        Text("Look at this new update!")
            .onAppear {
                Task {
                    try await migrateWorkouts()
                }
            }
        
        Spacer()
        
        Button {
            showUpdateView = false
        } label: {
            Text("Close")
        }
    }
}

private func migrateWorkouts() async throws {
    let db = Firestore.firestore()
    let collection = db.collection("workouts")
    var lastDoc: DocumentSnapshot? = nil
    let pageSize = 300

    while true {
        var query: Query = collection.order(by: FieldPath.documentID()).limit(to: pageSize)
        if let last = lastDoc {
            query = query.start(afterDocument: last)
        }

        let snapshot = try await query.getDocuments()
        if snapshot.documents.isEmpty { break }

        // Use a WriteBatch for efficiency
        let batch = db.batch()

        for doc in snapshot.documents {
            var data = doc.data()
//
//            // Example transformations:
//            // - Rename "desc" -> "description"
//            if let old = data["desc"] as? String {
//                data["description"] = old
//                data.removeValue(forKey: "desc")
//            }

            // - Add new field with default if absent
            if data["isPublic"] == nil {
                data["isPublic"] = false
            }

            // - Nest fields into a sub-object (e.g., metadata)
            // if let date = data["date"] as? Timestamp {
            //     var metadata = (data["metadata"] as? [String: Any]) ?? [:]
            //     metadata["lastUpdated"] = FieldValue.serverTimestamp()
            //     data["metadata"] = metadata
            // }

            batch.setData(data, forDocument: doc.reference, merge: true)
        }

        try await batch.commit()
        lastDoc = snapshot.documents.last
    }
}

#Preview {
    UpdateView(showUpdateView: .constant(false))
}
