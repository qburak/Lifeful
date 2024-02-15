import Foundation

struct Datas:Identifiable,Codable {
    var id:String
    var why:String
    var day:Int
    var date:Date
    var savingsStrings:Array<String>
    var savingsNumber:Array<Int>
    var savingsNumberStrings:Array<String>
    var whichDays:Array<Int>
}

