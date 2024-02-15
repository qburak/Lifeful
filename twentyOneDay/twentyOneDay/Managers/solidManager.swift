import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



struct Solid:Identifiable,Codable{
    var id:String
    var title:String
    var person:Int
    var url:String
    var language:String
    var emoji:[String]
    var exp:String
}
struct SolidOwn:Identifiable,Codable{
    var id:String
    var solidName:String
    var date:Date
    var savingsNumber:[Int]
    var savingsNumberStrings:[String]
    var savingsStrings:[String]
    var why:String
    var whichDays:[Int]
    var idOriginal:String
    var person:Int
    var moods:[String]
    var moodsDate:Date
    
    enum CodingKeys: String, CodingKey {
            case id
            case solidName = "solid_name"
            case date
            case savingsNumber = "savings_number"
            case savingsNumberStrings = "savings_number_strings"
            case savingsStrings = "savings_strings"
            case why
            case whichDays = "which_days"
            case idOriginal = "id_original"
            case person
            case moods
            case moodsDate = "moods_date"
        }
}

class solidManager:ObservableObject{
    @Published var solid:[Solid] = []
    @Published var solidList:[SolidOwn] = []
    
    let db = Firestore.firestore()
    
    
    func userRequest(solName:String) async throws {
        
        let userData = [
            "Solidarity_Name": solName
        ]
        try await db.collection("request").document("\(solName)").setData(userData)
    }
    func controlGP(solidName:String, completion:@escaping (Bool) -> Void){
        db.collection("solids").whereField("title", isEqualTo: solidName).getDocuments{(snapshot, error) in
            if let error = error{
                print("ERROR controlGP : \(error)")
                return
            }
            
            if let documentCount = snapshot?.documents.count{
                if (documentCount > 0){
                    completion(true)
                }else{
                    completion(false)
                }
            }
            
        }
    }
    func messageUrlLink(UID:String,comletion:@escaping (String?) -> Void){
        db.collection("users").document(UID).collection("profileData").document("profileData\(UID)").getDocument{ (snapshot,error) in
            if let error = error{
                print("ERROR messageUrlLink : \(error)")
                return
            }else if let document = snapshot, document.exists{
                if let urlID = document.data()?["photo_path"] as? String{
                    comletion(urlID)
                }else{
                    comletion(nil)
                }
            }else{
                print("GET URL LINK ERROR FIRST IF ELSE")
                comletion(nil)
            }
        }
    }
    func messageUserData(UID: String, completion: @escaping ((photoPath: String?, nick: String?)) -> Void){
        db.collection("users").document(UID).collection("profileData").document("profileData\(UID)").getDocument { (snapshot, error) in
            if let error = error {
                print("ERROR messageUrlLink : \(error)")
                return
            } else if let document = snapshot, document.exists {
                var urlID: String?
                var nick: String?

                if let photoPath = document.data()?["photo_path"] as? String {
                    urlID = photoPath
                }
                
                if let nickname = document.data()?["nick_name"] as? String {
                    nick = nickname
                }
                
                completion((urlID, nick))
            } else {
                print("GET URL LINK ERROR FIRST IF ELSE")
                completion((nil, nil))
            }
        }

    }
    func fPhotoUrlLink(UID:String){
        db.collection("users").document(UID).collection("profileData").document("profileData\(UID)").getDocument{ (snapshot,error) in
            if let error = error{
                print("ERROR messageUrlLink : \(error)")
                return
            }else if let document = snapshot, document.exists{
                if let urlID = document.data()?["photo_path"] as? String{
                    UserDefaults.standard.set(urlID, forKey: "photoPath")
                }else{
                    
                }
            }else{
                print("GET URL LINK ERROR FIRST IF ELSE")
                
            }
        }
    }
    func getUrlLink(orID:String,completion:@escaping (String?) -> Void){
        
        db.collection("solids").document(orID).getDocument{(snapshot,error) in
            
            if let error = error{
                print("ERROR getUrlLink: \(error)")
                return
            } else if let document = snapshot, document.exists{
                if let urlID = document.data()?["url"] as? String{
                    completion(urlID)
                }else{
                    completion(nil)
                }
                
            }else{
                print("GET URL LINK ERROR FIRST IF ELSE")
                completion(nil)
            }
            
        }
    }
    func getMember(title: String, completion: @escaping (Int?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("solids").document(title).getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
                return
            }

            if let document = document, document.exists {
                if let member = document.data()?["person"] as? Int {
                    completion(member, nil)
                } else {
                    print("Person value is not available or not in the expected format")
                    completion(nil, nil)
                }
            } else {
                print("Document does not exist")
                completion(nil, nil)
            }
        }
    }
    func deleteAllData(UID: String, subcollectionNames: [String]) async throws {
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(UID)

        for collectionName in subcollectionNames {
            let collectionRef = documentRef.collection(collectionName)
            let documents = try await collectionRef.getDocuments().documents
            for doc in documents {
                try await doc.reference.delete()
            }
        }

        // Ana belgeyi silme
        try await documentRef.delete()
    }


    /// kontrolden geçen solid'ler kullanıcıya sunulur..
    func fetchNonMatchingSolids(userId: String,prefix:String) {
        db.collection("users").document(userId).collection("solids").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching snapshot: \(error)")
                return
            }
            
            guard let userSolidDocuments = snapshot?.documents else {
                print("No documents in snapshot")
                return
            }
            
            let userSolidTitles = userSolidDocuments.compactMap { document -> String? in
                return document.data()["solid_name"] as? String
            }
            self.fetchSolidsExcludingTitles(prefix: prefix)
        }
    }
    func controlSolidHas(UID: String, title: String, completion: @escaping (String?) -> Void) {
        
        db.collection("users").document(UID).collection("solids").whereField("solid_name", isEqualTo: title).addSnapshotListener{ (snapshot, error) in
            if let error = error {
                print("Error fetchSolidName : \(error)")
                completion(nil)
                return
            }
            
            let id = snapshot?.documents.first?["id"] as? String
            completion(id)
        }
        
        
    }
    /// Solid var yok kontrol..
    func fetchSolidsExcludingTitles(prefix:String) {
        db.collection("solids").whereField("title", isGreaterThan: prefix.capitalizeFirstLetter()).whereField("title", isLessThan: prefix.capitalizeFirstLetter() + "\u{f8ff}").getDocuments{(snapshot,error) in ///xcode içinde hata vermesinin sebebi burdaki titles'dır
            guard let documents = snapshot?.documents else{
                print("Error fetching solids: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.solid = documents.compactMap{(queryDocumentSnapshot) -> Solid? in
                let solids = try? queryDocumentSnapshot.data(as:Solid.self)
                return solids
                
            }
        }
    }
    func createSolidControl(createTitle:String,completion:@escaping (Bool) -> Void){
        db.collection("solids").whereField("title", isEqualTo: createTitle).getDocuments{ (snapshot,error) in
            if let error = error {
                print("ERROR : oluşturulan title kontrol edilirken hata oluştu")
                completion(false)
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty{
                completion(false)
            }
            if let documents = snapshot?.documents, documents.isEmpty{
                completion(true)
            }
            
        }
    }
    
    /// Kullanıcı Yaratır ekler.
    func addSolid(title:String,exp:String) async throws{
        let solidRef = db.collection("solids").document()
        
        let solidDatas = Solid(id: "\(solidRef.documentID)", title:title, person: 0, url: "urlLink", language: "en", emoji: ["🙂","🙂","🙂"], exp: "\(exp)")
        do{
            try solidRef.setData(from : solidDatas)
        }catch{
            print("from addSolid error : \(error)")
        }
    }
    
    func setupSolid(UID:String,id:String,why:String,whichDays:[Int],savingsStrings:[String],savingsNumber:[Int],savingsNumberStrings:[String])async throws{
        let setupSolid:[String :Any] = [
            "savings_number": savingsNumber,
            "savings_number_strings" : savingsNumberStrings,
            "savings_strings" : savingsStrings,
        ]
        try await db.collection("users").document(UID).collection("solids").document(id).updateData(setupSolid)
    }
    
    func setupMood(UID:String,id:String,Date:Date,Moods:[String])async throws{
        let setupSolid:[String :Any] = [
            "moods_date": Date,
            "moods": Moods
        ]
        try await db.collection("users").document(UID).collection("solids").document(id).updateData(setupSolid)
    }
    
    
    
    func setupSave(UID:String,id:String,savingsStrings:[String],savingsNumber:[Int],savingsNumberStrings:[String])async throws{
        let setupSolid:[String :Any] = [
            "savings_number": savingsNumber,
            "savings_number_strings" : savingsNumberStrings,
            "savings_strings" : savingsStrings,
        ]
        try await db.collection("users").document(UID).collection("solids").document(id).updateData(setupSolid)
    }
    func setupWD(UID:String,id:String,whichDays:[Int])async throws{
        let setupSolid:[String :Any] = [
            "which_days": whichDays
        ]
        try await db.collection("users").document(UID).collection("solids").document(id).updateData(setupSolid)
    }
    
    func setupWhy(UID:String,id:String,why:String)async throws{
        let setupSolid:[String :Any] = [
            "why": why
        ]
        try await db.collection("users").document(UID).collection("solids").document(id).updateData(setupSolid)
    }
    
    func sendPlaint(quiltyId:String,quiltyEntryText:String,section:String) async throws{
        let plaintData:[String : Any] = [
            "quilty_id" : quiltyId,
            "quilty_entry_text":quiltyEntryText
        ]
        
        try await db.collection("plaints").document("section").collection("\(section)").addDocument(data: plaintData)
    }
    
    func sendAppeal(UTDId:String,eMail:String) async throws{
        let plaintData:[String : Any] = [
            "UID" : UTDId,
            "email" : eMail
        ]
        
        try await db.collection("appeals").document(UTDId).collection("APPEAL").addDocument(data: plaintData)
    }

    
    func reset(id:String) async throws{
        let reset:[String :Any] = [
            "date": Date()
        ]
        try await db.collection("users").document(ID.userUID).collection("solids").document(id).updateData(reset)
        
    }
    
    func deleteSolid(UID:String,DOCID:String,realDocID:String) async throws{
        try await db.collection("users").document(UID).collection("solids").document(DOCID).delete()
        let solidCount:[String:Any] = [
            "person" : FieldValue.increment(Int64(-1))
        ]
        let solCount:[String:Any] = [
            "profile_sol" : FieldValue.increment(Int64(-1))
        ]
        try await db.collection("users").document(UID).collection("profileData").document("profileData\(UID)").updateData(solCount)
        try await db.collection("solids").document(realDocID).updateData(solidCount)
    }
    /// Kullanıcı Solid'e katılır..
    func saveSolid(solid: SolidOwn, userId: String, docId: String) async throws {
        let docRef = db.collection("users").document(userId).collection("solids").document()
        
        let solidSave: [String: Any] = [
            "id": docRef.documentID,
            "solid_name": solid.solidName,
            "date": Timestamp(date: solid.date),
            "savings_number": solid.savingsNumber,
            "savings_number_strings": solid.savingsNumberStrings,
            "savings_strings": solid.savingsStrings,
            "why": solid.why,
            "which_days": solid.whichDays,
            "id_original": docId,
            "person": solid.person,
            "moods": solid.moods,
            "moods_date":solid.moodsDate
        ]
        
        let solidCount: [String: Any] = [
            "person": FieldValue.increment(Int64(1))
        ]
        
        let solCount:[String:Any] = [
            "profile_sol" : FieldValue.increment(Int64(1))
        ]
        try await db.collection("users").document(userId).collection("profileData").document("profileData\(userId)").updateData(solCount)
        
        try await docRef.setData(solidSave, merge: true)
        try await db.collection("solids").document(docId).updateData(solidCount)
    }
    
    
    
    func readOwnSolid(userId: String) async throws {
        
        db.collection("users").document(userId).collection("solids").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents in snapshot")
                return
            }
            
            self.solidList = documents.compactMap { document in
                var solidData = document.data()
                if let timestamp = solidData["date"] as? Timestamp {
                    solidData["date"] = timestamp.dateValue()
                }
                return try? document.data(as: SolidOwn.self)
            }
        }
        
        
    }
    
}
extension String {
    func capitalizeFirstLetter() -> String {
        return self.lowercased().split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
}
