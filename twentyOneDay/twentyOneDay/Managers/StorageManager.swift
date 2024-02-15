import Foundation
import UIKit
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    private init (){}
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference:StorageReference{
        storage.child("profilePhotos")
    }
     
    private func userRefenrece(userUID:String) -> StorageReference{
        storage.child("users").child(userUID)
    }
    func getPathForImage(path:String) -> StorageReference{
        Storage.storage().reference(withPath: path)
    }
    func saveImage(data:Data,userUID:String) async throws -> (path:String, name:String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userRefenrece(userUID: userUID).child(path).putDataAsync(data,metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else{
            throw URLError(.badServerResponse)
        }
        
        return(returnedPath,returnedName)
    }
    func saveImage(image:UIImage,userUID:String) async throws -> (path:String,name:String){
        guard let data = image.jpegData(compressionQuality: 1) else{
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, userUID: ID.userUID)
    }
    
    func getUrlForImage(path:String) async throws -> URL{
        try await getPathForImage(path: path).downloadURL()
    }
    func getData(userUID:String,path:String) async throws -> Data{
     //   try await userRefenrece(userUID: userUID).child(path).data(maxSize: 3*1024*1024)
        try await storage.child(path).data(maxSize: 3*1024*1024)
    }
    
    func getImage(userUID:String,path:String) async throws -> UIImage{
        let data = try await getData(userUID: userUID, path: path)
        
        guard let image = UIImage(data: data) else{
            throw URLError(.badServerResponse)
        }
        return image
    }

}
