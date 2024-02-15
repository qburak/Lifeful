import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class messagesManager: ObservableObject{
    @Published var messages: [Message] = []
    @Published private(set) var vProfile:visitProfleDB? = nil

    @Published private (set) var lastMessageId = ""
    let db = Firestore.firestore()
    
    var lastDocumentSnapshot: DocumentSnapshot?
    private var isFetchingMore = false


    func deleteMessage(sol:String,id:String) async throws{
       try await db.collection("solidarity-messages").document(sol).collection("chat").document(id).delete()
    }
    func deleteMessageHide(sol:String,UID:String,Name:String,Date:Date,Text:String) async throws{
        let setupSolid:[String :Any] = [
            "Solidarity_Name": sol,
            "User_Id" : UID,
            "Username" : Name,
            "Date" : Date,
            "Message" : Text
        ]
        try await db.collection("deleteHide").document("\(UID)\(Date.timeIntervalSince1970)").setData(setupSolid)
    }
    func getMessages(sol: String) async throws {
           let query = db.collection("solidarity-messages")
                         .document(sol)
                         .collection("chat")
                         .order(by: "time", descending: true)
                         .limit(to: 25)

           query.addSnapshotListener { (querySnapshot, error) in
               guard let documents = querySnapshot?.documents else {
                   print("ERROR \(error)")
                   return
               }
               self.messages = documents.compactMap { document -> Message? in
                   do {
                       return try document.data(as: Message.self)
                   } catch {
                       print("ERROR \(error)")
                       return nil
                   }
               }
               self.messages.sort { $0.time < $1.time }
               self.lastDocumentSnapshot = documents.last
               
               self.lastMessageId = self.messages.last?.id ?? "1"
           }
       }
    func loadMoreMessage(sol:String){

        guard let lastSnapshot = lastDocumentSnapshot, !isFetchingMore else{return}
        
        isFetchingMore = true
        
        let query = db.collection("solidarity-messages")
            .document(sol)
            .collection("chat")
            .order(by: "time", descending: true)
            .start(afterDocument: lastSnapshot)
            .limit(to: 25)
        
        query.addSnapshotListener{ (snapshot,error) in
            
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var newMessages = documents.compactMap { document -> Message? in
                try? document.data(as: Message.self)
            }
            newMessages.sort { $0.time < $1.time}
            self.lastMessageId = newMessages.last!.id
            self.messages.append(contentsOf: newMessages)
            self.messages.sort { $0.time < $1.time}
            self.lastDocumentSnapshot = documents.last
            self.isFetchingMore = false
        }
    }

    func sendMessage(text:String,dayString:Int,sol:String,UTDId:String,UTDName:String){
        do{
            let collRef = db.collection("solidarity-messages").document(sol).collection("chat").document()
            
            let newMessage = Message(id: "\(collRef.documentID)",uid: UTDId, text: text, received: false, time: Date(), nick: UTDName,dayString: dayString)
            
            try collRef.setData(from: newMessage)
        }catch{
            print("ERROR \(error)")
        }
    }
    func messageTime(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.string(from: date)
        
        let timeString = dateFormatter.string(from: date)
        return timeString
    }
    
    func loadVisitProfile(UID:String) async throws{
        db.collection("users").document(UID).collection("profileData").document("profileData\(UID)")
    }
   
    
    private func profileDocCollection(userId:String) -> DocumentReference{
        
        db.collection("users").document(userId).collection("profileData").document("profileData\(userId)")
    }
    
    func visitedProfileReader(userId:String) async throws -> visitProfleDB{
        try await profileDocCollection(userId: userId).getDocument(as: visitProfleDB.self,decoder: decoder)
    }
    
    private let decoder:Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    struct visitProfleDB: Codable {
        var nickName: String?
           var photoPath: String?
           var profileEntry: Int?
           var profileSol: Int?
           var profileEntryLike: Int?
    }
    func loadVisitedProfile(UID:String) async throws{
        do{
            self.vProfile = try await visitedProfileReader(userId: UID)
        }
    }
}
