import Foundation
import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct profileCounts:Codable{
    var sol:Int
    var entry:Int
    var entryLike:Int
    
    enum CodingKeys: String, CodingKey{
        case sol = "profile_sol"
        case entry = "profile_entry"
        case entryLike = "profile_entry_like"
    }
}

@MainActor
final class ProfileViewModel:ObservableObject{
    @Published var isSuccessful: Bool = false
    @Published var profileCountsList:profileCounts? = nil
    @Published private(set) var user:DBUser? = nil
    @Published private(set) var Puser:DBProfileData? = nil
    @Published var names: [String: String?] = [:]

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        do{
            self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            UserDefaults.standard.set(user?.userId, forKey: "userUIDD")
            
        }catch{
        }
        do{
            self.Puser = try await UserManager.shared.userProfilDataRead(userId: authDataResult.uid)
        }catch{
            print("\(error)")
        }
    }
    
    func saveProfileImage(item:PhotosPickerItem,UID:String,isSuccess: Binding<Bool>) async throws{
        guard let user else{return}
        
        
        Task{
            
            guard let data = try await item.loadTransferable(type: Data.self) else{ return}
            
            let (path,name) = try await StorageManager.shared.saveImage(data: data, userUID: UID)
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            do{
                try await UserManager.shared.updateUserProfileImagePath(userUID: UID, path: url.absoluteString)
                isSuccess.wrappedValue = true
                print("duyamadım \(url)")
                UserDefaults.standard.set(url.absoluteString, forKey: "photoPath")
            }catch{
                
            }
            
        }
        
    }
    func saveFirstPP(item:PhotosPickerItem,UID:String) async throws{
        guard let user else{return}
        
        
        Task{
            
            guard let data = try await item.loadTransferable(type: Data.self) else{ return}
            
            let (path,name) = try await StorageManager.shared.saveImage(data: data, userUID: ID.userUID)
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            
            try await UserManager.shared.updateUserProfileImagePath(userUID: UID, path: url.absoluteString)
            UserDefaults.standard.set(url.absoluteString, forKey: "photoPath")
        }
        
    }
    func entryUserInfo(userId:String) async throws{
        do{
            self.Puser = try await UserManager.shared.userProfilDataRead(userId: userId)
        }catch{
            print("\(error)")
        }
    }
    func deleteImage(UID:String) async throws{
        let storageRef = Storage.storage().reference().child("users").child("\(UID)")
        
        
        // Klasör içerisindeki tüm dosyaları listele
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Dosyaları listelerken hata oluştu: \(error.localizedDescription)")
                return
            }
            
            // Her bir dosyayı sil
            for item in result!.items {
                item.delete { error in
                    if let error = error {
                        print("Dosyayı silerken hata oluştu: \(error.localizedDescription)")
                    } else {
                        print("\(item.name) başarıyla silindi!")
                    }
                }
            }
        }
        //   try await getPathForImage(path: path).delete()
    }
    
    func getProfileCounts(UID: String) async throws{
        let db = Firestore.firestore()
        db.collection("users").document(UID).collection("profileData").document("profileData\(UID)").getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.profileCountsList = try document.data(as: profileCounts.self)
                } catch {
                    print("Hata: Veri çekilemedi")
                }
            } else {
                print("Belge mevcut değil")
            }
        }
    }
    

    func unBlock(UTDId: String, blockUID: String) async throws {
        let db = Firestore.firestore()
        let profileDataRef = db.collection("users").document(UTDId).collection("profileData").document("profileData\(UTDId)")

        let documentSnapshot = try await profileDataRef.getDocument()

        if documentSnapshot.exists {
            var blocks = documentSnapshot.data()?["blocks"] as? [String] ?? []
            
            if let index = blocks.firstIndex(of: blockUID) {
                blocks.remove(at: index)
                try await profileDataRef.updateData(["blocks": blocks])
            }
        } else {
            print("Document does not exist")
        }
    }
  


    func getNames(blockedUIDs: [String], completion: @escaping ([String: String?]) -> Void) {
        var names: [String: String?] = [:]
        let group = DispatchGroup()

        for uid in blockedUIDs {
            group.enter()
            Firestore.firestore().collection("users").document(uid).collection("profileData").document("profileData\(uid)").getDocument { (snapshot, error) in
                defer { group.leave() }

                if let error = error {
                    print("Error getting document: \(error)")
                    names[uid] = nil
                    return
                }

                if let document = snapshot, document.exists {
                    let name = document.data()?["nick_name"] as? String
                    names[uid] = name
                } else {
                    print("Document does not exist")
                    names[uid] = nil
                }
            }
        }

        group.notify(queue: .main) {
            completion(names)
        }
    }
    func fetchNames(blockedUIDs: [String]) {
        getNames(blockedUIDs: blockedUIDs) { namesDict in
               DispatchQueue.main.async {
                   self.names = namesDict
               }
           }
       }

    
  
}
