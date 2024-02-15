import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
struct DBUser:Codable{
    let userId:String
    let userNick:String?
    let joinDate:Date?
    let photoUrl:String?
    
    init(auth:AuthDataResultModel){
        self.userId = auth.uid
        self.userNick = auth.nick
        self.joinDate = Date()
        self.photoUrl = auth.photoUrl
    }
}
struct DBProfileData:Codable{
    let nickName:String?
    let photoPath:String?
    let profileEntry:Int?
    let profileSol:Int?
    let profileEntryLike:Int?
    let blocks:[String]?
    let ban:Bool?
}


final class UserManager{
    static let shared = UserManager()
    private init(){}
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId:String) -> DocumentReference{
        userCollection.document(userId)
    }
    private func userDocumentCol(userId:String) -> CollectionReference{
        
        userCollection.document(userId).collection("sols")
        
    }
    
    private func userDocCollection(userId:String) -> DocumentReference{
        
        userCollection.document(userId).collection("profileData").document("profileData\(userId)")
        
    }
    
    private func userPathEntry(userId:String) -> CollectionReference{
        Firestore.firestore().collection("sol-entry")
    }
    
    private let encoder:Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder:Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user:DBUser) async throws{
        try userDocument(userId: user.userId).setData(from: user,merge:false,encoder: encoder)
    }
    
    func getUser(userId:String) async throws -> DBUser{
        try await userDocument(userId: userId).getDocument(as: DBUser.self,decoder: decoder)
    }
    func userProfilDataRead(userId:String) async throws -> DBProfileData{
        try await userDocCollection(userId: userId).getDocument(as: DBProfileData.self,decoder: decoder)
    }
    func userEntryCount(userId:String) async throws -> Int{
        let entryCount = try await userPathEntry(userId: userId).whereField("id", isEqualTo: userId).getDocuments().count
        return entryCount
    }
    func userSolCount(userId:String) async throws -> Int{
        let solCount = try await userDocumentCol(userId: userId).getDocuments().count
        return solCount
    }
    
    func userProfileData(userProfileData:DBProfileData,userUID:String) async throws {
        
        try userDocCollection(userId: userUID).setData(from: userProfileData,encoder: encoder)
        
    }
    func userDataControl(uuid: String, completion: @escaping (Bool) -> Void) {
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uuid).collection("profileData")
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
            } else {
                if querySnapshot!.documents.count > 0 {
                    print("Collection exists")
                    completion(true)
                } else {
                    print("Collection does not exist")
                    completion(false)
                }
            }
        }
    }
    
    func updateprofileDatasAll(userUID:String,userEntryNumber:Int,userSolNumber:Int,userEntryLikeNumber:Int) async throws{
        let data:[String:Any] = [
            "profile_entry" : userEntryNumber,
            "profile_sol" : userSolNumber,
            "profile_entry_like" : userEntryLikeNumber
        ]
        try await userDocCollection(userId: userUID).updateData(data)
    }
    func updateUserProfileImagePath(userUID:String,path:String) async throws{
        let data:[String:Any] = [
            "photo_path" : path
        ]
        
        try await userDocCollection(userId: userUID).updateData(data)
        
    }
    func updateEditUserNickName(userUID:String,nickName:String) async throws{
        let data:[String:Any] = [
            "nick_name" : nickName
        ]
        try await userDocCollection(userId: userUID).updateData(data)
    }
    
}
      //let entryCount = try await userPathEntry(userId: userId).whereField("id", isEqualTo: userId).getDocuments().count
