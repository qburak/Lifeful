import Foundation

struct Message:Identifiable,Codable {
    var id:String
    var uid:String
    var text:String
    var received:Bool
    var time:Date
    var nick:String
    var dayString:Int
}
