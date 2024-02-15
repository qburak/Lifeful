import Firebase
import SwiftUI
import FirebaseFirestore
import Foundation


struct SolEntry: Identifiable,Codable {
    var id: String
    var text: String
    var day: Int
    var sol: String
    var stage: Int
    var time: Date
    var emoji: String
    var userid:String
    var likes:Int

}
struct DBProfileDataS: Codable {
    let nickName: String?
    let photoPath: String?
    let profileEntry: Int?
    let profileSol: Int?
    let profileEntryLike: Int?

    init?(dictionary: [String: Any]) {
        self.nickName = dictionary["nick_name"] as? String
        self.photoPath = dictionary["photo_path"] as? String
        self.profileEntry = dictionary["profileEntry"] as? Int
        self.profileSol = dictionary["profileSol"] as? Int
        self.profileEntryLike = dictionary["profileEntryLike"] as? Int
    }
}


class SolEntryViewModel: ObservableObject {
    @Published var solEntries: [SolEntry] = []
    private var lastDocumentSnapshot: DocumentSnapshot?
    private var isFetchingMore = false
    
    private var db = Firestore.firestore()
   
    func fetchInitialSolEntries(all: Bool, stage: Int, sol: String, emoji: String) {
          let db = Firestore.firestore()
        var query: Query = db.collection("sol-entry")
            .limit(to: 5)

          applyFilters(query: &query, all: all, stage: stage, sol: sol, emoji: emoji)

          query.addSnapshotListener { (snapshot, error) in
              guard let documents = snapshot?.documents else {
                  print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }

              self.solEntries = documents.compactMap { document -> SolEntry? in
                  try? document.data(as: SolEntry.self)
              }

              self.lastDocumentSnapshot = documents.last
          }
      }

      func fetchMoreSolEntries(all: Bool, stage: Int, sol: String, emoji: String) {
          guard let lastSnapshot = lastDocumentSnapshot, !isFetchingMore else { return }

          isFetchingMore = true

          let db = Firestore.firestore()
          var query: Query = db.collection("sol-entry").start(afterDocument: lastSnapshot).limit(to: 5)

          applyFilters(query: &query, all: all, stage: stage, sol: sol, emoji: emoji)

          query.addSnapshotListener { (snapshot, error) in
              
              guard let documents = snapshot?.documents else {
                  print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }

              let newEntries = documents.compactMap { document -> SolEntry? in
                  try? document.data(as: SolEntry.self)
              }

              self.solEntries.append(contentsOf: newEntries)
              self.lastDocumentSnapshot = documents.last
              self.isFetchingMore = false
          }
      }

      private func applyFilters(query: inout Query, all: Bool, stage: Int, sol: String, emoji: String) {
          query = query.whereField("stage", isEqualTo: stage)

          if !all {
              query = query.whereField("sol", isEqualTo: sol)
          }
          
          if emoji != "-" {
              query = query.whereField("emoji", isEqualTo: emoji)
          }
      }

    func banUser(userId:String) async throws{
        db = Firestore.firestore()
        
        db.collection("sol-entry").whereField("userid", isEqualTo: userId).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Hata: \(err)")
            } else {
                // Sorgu sonucunda dönen her belge için
                for document in querySnapshot!.documents {
                    print("Silinecek belge ID: \(document.documentID)")

                    // Belgeyi sil
                    self.db.collection("sol-entry").document(document.documentID).delete() { err in
                        if let err = err {
                            print("Belge silinirken hata oluştu: \(err)")
                        } else {
                            print("Belge başarıyla silindi")
                        }
                    }
                }
            }
        }
        db.collection("solidarity-messages").getDocuments { (parentQuerySnapshot, parentErr) in
            if let parentErr = parentErr {
                print("Hata: \(parentErr)")
            } else {
                for parentDocument in parentQuerySnapshot!.documents {
                    let parentDocumentId = parentDocument.documentID

                    // Alt koleksiyondaki belgeleri sorgula
                    parentDocument.reference.collection("chat").whereField("uid", isEqualTo: userId).getDocuments { (childQuerySnapshot, childErr) in
                        if let childErr = childErr {
                            print("Hata: \(childErr)")
                        } else if childQuerySnapshot!.documents.count > 0 {
                            // Eşleşen bir belge varsa, ana belgeyi sil
                            parentDocument.reference.delete() { err in
                                if let err = err {
                                    print("\(parentDocumentId) belgesi silinirken hata oluştu: \(err)")
                                } else {
                                    print("\(parentDocumentId) belgesi başarıyla silindi")
                                }
                            }
                        }
                    }
                }
            }
        }
        try await db.collection("users").document(userId).collection("profileData").document("profileData\(userId)").updateData(["ban": true])

    }
    
    func soulCount(userId:String) async throws -> Int{
        let solCount = try await db.collection("users").document(userId).collection("sols").getDocuments().count
        return solCount
    }
    
    func entryCount(userId:String) async throws -> Int{
        let solCount = try await db.collection("sol-entry").whereField("userid", isEqualTo: userId).getDocuments().count
        return solCount
    }
    
    func entryLikeCount(userId:String) async throws -> Int{
        let entryLikeCount = try await db.collection("likes").whereField("sol_entry_owner_id", isEqualTo: userId).getDocuments().count
        return entryLikeCount
    }
    func deleteEntryHide(sol:String,text:String,UID:String,Date:Date,Name:String) async throws{
            let setupSolid:[String :Any] = [
                "Solidarity_Name": sol,
                "User_Id" : UID,
                "Username" : Name,
                "Date" : Date,
                "Entry" : text
            ]
        try await db.collection("deleteEntry").document("\(UID)\(Date.description)").setData(setupSolid)
        
    }
    func deleteEntry(entry:SolEntry,userId:String){
        db.collection("sol-entry").document(entry.id).delete()
        
        db.collection("likes").whereField("sol_entry_id", isEqualTo: entry.id).getDocuments{(snapshot,error) in
            if error != nil{
                print("entry delete error : \(String(describing: error))")
            }else{
                for document in snapshot!.documents{
                    self.db.collection("likes").document(document.documentID).delete { err in
                        if err != nil{
                            print("Silinmede hata oluştu.")
                        }else{
                            print("Başarıyla silindi.")
                        }
                    }
                }
            }
        }
        
        let entryCountData:[String : Any] = [
            "profile_entry" : FieldValue.increment(Int64(-1))
        ]
        db.collection("users").document(userId).collection("profileData").document("profileData\(userId)").updateData(entryCountData)
   
    }
    func block(UTDId: String, blockUID: String) async throws {
        let db = Firestore.firestore()
        
        // "blocks" array'ine yeni bir eleman eklemek için FieldValue.arrayUnion kullanın
        let data: [String: Any] = [
            "blocks": FieldValue.arrayUnion([blockUID])
        ]

        // Bu veriyi Firestore'a gönderin
        try await db.collection("users").document(UTDId).collection("profileData").document("profileData\(UTDId)").updateData(data)
    }
    func contract(UTDId: String) async throws {
        let db = Firestore.firestore()
        
        // "blocks" array'ine yeni bir eleman eklemek için FieldValue.arrayUnion kullanın
        let data: [String: Any] = [
            "contract": false
        ]

        // Bu veriyi Firestore'a gönderin
        try await db.collection("users").document(UTDId).collection("profileData").document("profileData\(UTDId)").updateData(data)
    }
   
    func likeEntry(entry: SolEntry, userId: String) {
        // Beğeni sayısını artır
        let entryRef = db.collection("sol-entry").document(entry.id)
        entryRef.updateData([
            "likes": FieldValue.increment(Int64(1))
        ])
        
        // "likes" koleksiyonuna yeni bir beğeni ekle
        let likeData:[String : Any] = [
            "userid" : userId,
            "sol_entry_id" : entry.id,
            "sol_entry_owner_id" : entry.userid
        ]
        db.collection("likes").addDocument(data: likeData)
        
        let likeCountData:[String : Any] = [
            "profile_entry_like" : FieldValue.increment(Int64(1))
        ]
        db.collection("users").document(userId).collection("profileData").document("profileData\(userId)").updateData(likeCountData)
    }
    
    func unLikeEntry(entry:SolEntry,userId:String){
        let entryRef = db.collection("sol-entry").document(entry.id)
        entryRef.updateData([
            "likes" : FirebaseFirestore.FieldValue.increment(Int64(-1))
        ])
        
        db.collection("likes").whereField("userid", isEqualTo: userId).whereField("sol_entry_id", isEqualTo: entry.id).getDocuments{ (snapshot,error)in
            if let docs = snapshot?.documents{
                for doc in docs {
                    doc.reference.delete()
                }
            }
               
        }
        let likeCountData:[String : Any] = [
            "profile_entry_like" : FieldValue.increment(Int64(-1))
        ]
        db.collection("users").document(userId).collection("profileData").document("profileData\(userId)").updateData(likeCountData)
   
    }
    func didUserLike(entry: SolEntry, userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("likes")
            .whereField("userid", isEqualTo: userId)
            .whereField("sol_entry_id", isEqualTo:  entry.id)
            .addSnapshotListener { (snapshot, error) in
                if let count = snapshot?.documents.count {
                    completion(count > 0)
                } else {
                    completion(false)
                }
            }
    }

    func sendData(text: String, day: Int, solidarityName: String, stage: Int, emoji: String,UTDId:String) async throws {
        // 1. Belge referansını oluşturun
        let newDocumentRef = db.collection("sol-entry").document()

        // 2. Belge referansının ID'sini kullanarak modeli oluşturun
        let newEntry = SolEntry(id: newDocumentRef.documentID, text: text, day: day, sol: solidarityName, stage: stage, time: Date(), emoji: emoji, userid: UTDId, likes: 0)

        // 3. Modeli belge referansına kaydedin
        do {
            try newDocumentRef.setData(from: newEntry)
        } catch {
            print("ERROR \(error)")
        }
        
        let entryCountData:[String : Any] = [
            "profile_entry" : FieldValue.increment(Int64(1))
        ]
        try await db.collection("users").document(UTDId).collection("profileData").document("profileData\(UTDId)").updateData(entryCountData)
   
    }


    

    func fetchProfileData(for userID: String, completion: @escaping (Result<DBProfileDataS, Error>) -> Void) {
        let db = Firestore.firestore()

        // Öncelikle belirtilen yola bir referans oluşturuyoruz.
        let profileDataRef = db.collection("users").document(userID).collection("profileData").document("profileData\(userID)")

        // Şimdi bu referans üzerinden veriyi çekiyoruz.
        profileDataRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "-*domain*-", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }

            // Eğer modeliniz Firestore'dan dönen veriyi map edebilirse
            if let profileData = DBProfileDataS(dictionary: data) {
                completion(.success(profileData))
            } else {
                completion(.failure(NSError(domain: "-*domain*-", code: -2, userInfo: [NSLocalizedDescriptionKey: "Data mapping error"])))
            }
        }
    }
   


}

