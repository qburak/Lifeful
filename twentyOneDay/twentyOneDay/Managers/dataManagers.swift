import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class dataManagers: ObservableObject {
    @Published private (set) var datas:[Datas] = []
    @Published private (set) var data:[Datas] = []
    @Published private (set) var titles: [String] = []

    let db = Firestore.firestore()
    
    init(){
        getOwnSolidarity(userId: UserDefaults.standard.string(forKey: "userUIDD") ?? "*original-id*")
    }

    
    func saveDataToFirestore(datas: [Datas]) {
        let db = Firestore.firestore()
        for data in datas {
            let docData: [String: Any] = [
                "id": data.id,
                "why": data.why,
                "day": data.day,
                "date": data.date
            ]
            db.collection("solidarity-adictions").document("firstWall").collection("XXX").document("Ventriha").setData(docData)
        }
    }
    func getDetailSolidarity(nickName:String,solidarityName:String) {
        
        db.collection("users").document("Ventriha").collection("adictions").document(solidarityName).getDocument { (document, error) in
                    if let document = document, document.exists {
                        do {
                            let result = try document.data(as: Datas.self)
                            self.data = [result]
                        } catch {
                            print("Error decoding data: \(error)")
                        }
                    } else {
                        print("Document not found")
                    }
                }
    }
    func getOwnSolidarity(userId:String) {
        db.collection("users").document(userId).collection("sols").addSnapshotListener{ QuerySnapshot,error in
            guard let documents = QuerySnapshot?.documents else{
                print("ERROR\(error)")
                return
            }
            
            self.datas = documents.compactMap{ document -> Datas? in
                do{
                    return try document.data(as: Datas.self)
                }catch{
                    print("ERROR \(error)")
                    return nil
                }
            }
            
        }
    }
 




}

