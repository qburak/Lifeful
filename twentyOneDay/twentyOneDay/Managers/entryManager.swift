import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct Entrys: Identifiable, Codable {
    var id: String
    var text: String
    var day: Int
    var sol: String
    var stage: Int
    var time: Date
    var emoji: String
}

final class entryManager:ObservableObject{
    let db = Firestore.firestore()
    
    init(){}
    
    private let encoder:Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
  

    func sendEntry(text:String,day:Int,solidarityName:String,stage:Int,emoji:String){
        do{
            let newEntry = Entrys(id: "\(UUID())", text: text, day: day, sol: solidarityName, stage: stage, time: Date(), emoji:emoji)
            try db.collection("solidarity-messages").document("entry").collection("test-entrys").document().setData(from:newEntry)
        }catch{
                print("ERROR \(error)")
        }
    }
    
    func entryControl(nick: String,stage:Int, completion: @escaping (Bool) -> Void) {
        db.collection("solidarity-messages").document("entry").collection("test-entrys")
            .whereField("nick", isEqualTo: nick)
            .whereField("stage", isEqualTo: stage)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(false)
                } else {
                    if querySnapshot!.documents.isEmpty {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }


    func entryTime(date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, HH:mm"
        dateFormatter.string(from: date)
        
        let timeString = dateFormatter.string(from: date)
        return timeString
    }
    
    func entryStageMath(actualDay:Int) -> (Int,Int,adictionStage,Int){
        var stage:Int = 0
        var lastDay:Int = 0
        var firstDay:Int = 0
        var stageD:adictionStage = .awareness
        
        switch actualDay{
        case ...3:
            stage = 1
            lastDay = 3
            firstDay = 1
            stageD = .awareness
        case 4...7:
            stage = 2
            lastDay = 7
            firstDay = 4
            stageD = .struggle

        case 8...15:
            stage = 3
            lastDay = 15
            firstDay = 8
            stageD = .adaptation
            
        case 16...30:
            stage = 4
            lastDay = 30
            firstDay = 16
            stageD = .rebuilding
        case 31...60:
            stage = 5
            lastDay = 60
            firstDay = 31
            stageD = .strengthening
        case 61...90:
            stage = 6
            lastDay = 90
            firstDay = 61
            stageD = .integration
        case 91...120:
            stage = 7
            lastDay = 120
            firstDay = 91
            stageD = .empowerment
        case 121...150:
            stage = 8
            lastDay = 150
            firstDay = 121
            stageD = .confidence
        case 151...180:
            stage = 9
            lastDay = 180
            firstDay = 151
            stageD = .discovery
        case 181...210:
            stage = 10
            lastDay = 210
            firstDay = 181
            stageD = .resilience
        case 211...240:
            stage = 11
            lastDay = 240
            firstDay = 211
            stageD = .transition
        case 241...270:
            stage = 12
            lastDay = 270
            firstDay = 241
            stageD = .growth
        case 271...300:
            stage = 13
            lastDay = 300
            firstDay = 271
            stageD = .redefinition
        case 301...330:
            stage = 14
            lastDay = 330
            firstDay = 301
            stageD = .control
        case 331...360:
            stage = 15
            lastDay = 360
            firstDay = 331
            stageD = .mastery
        default:
            stage = 16
            lastDay = 980
            firstDay = 361
            stageD = .mastery
        }
        
        return (stage,lastDay,stageD,firstDay)
      
    }
}

enum adictionStage {
    case awareness
    case struggle
    case adaptation
    case rebuilding
    case strengthening
    case integration
    case empowerment
    case confidence
    case discovery
    case resilience
    case transition
    case growth
    case redefinition
    case control
    case mastery
    
    var title:String{
        switch self {
        case .awareness:
            return "The Early Awakening Period"
        case .struggle:
            return "Period of Struggle"
        case .adaptation:
            return "Adaptation Period"
        case .rebuilding:
            return "Reconstruction Period"
        case .strengthening:
            return "Period of Empowerment"
        case .integration:
            return "Integration Period"
        case .empowerment:
            return "The Era of Inner Strength"
        case .confidence:
            return "A Period of Confidence"
        case .discovery:
            return "Period of Discovery"
        case .resilience:
            return "Period of Independence"
        case .transition:
            return "Adaptation Period"
        case .growth:
            return "Personal Development Period"
        case .redefinition:
            return "A Period of Redefinition"
        case .control:
            return "Control Period"
        case .mastery:
            return "Rebirth and Mastery"
        }
    }
    var day:String{
        switch self{
        case .awareness:
            return "1-3"
        case .struggle:
            return "4-7"
        case .adaptation:
            return "8-15"
        case .rebuilding:
            return "16-30"
        case .strengthening:
            return "31-60"
        case .integration:
            return "61-90"
        case .empowerment:
            return "91-120"
        case .confidence:
            return "121-150"
        case .discovery:
            return "151-180"
        case .resilience:
            return "181-210"
        case .transition:
            return "211-240"
        case .growth:
            return "241-270"
        case .redefinition:
            return "271-300"
        case .control:
            return "301-330"
        case .mastery:
            return "331-360"

        }
    }
    var leftDay:Int{
        switch self{
        case .awareness:
            return 3
        case .struggle:
            return 7
        case .adaptation:
            return 15
        case .rebuilding:
            return 30
        case .strengthening:
            return 60
        case .integration:
            return 90
        case .empowerment:
            return 120
        case .confidence:
            return 150
        case .discovery:
            return 180
        case .resilience:
            return 210
        case .transition:
            return 240
        case .growth:
            return 270
        case .redefinition:
            return 300
        case .control:
            return 330
        case .mastery:
            return 360

        }
    }
}
