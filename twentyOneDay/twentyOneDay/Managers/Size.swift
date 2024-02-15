
import SwiftUI

struct Size{
    
    static var sizeLarge:CGFloat = 18
    static var sizeMedium:CGFloat = 14
    static var sizeSmall:CGFloat = 12
    static var sizeUltraLarge:CGFloat = 35
}
struct ID{
    
    static var userUID:String = UserDefaults.standard.string(forKey: "userUIDD") ?? "ERROR"
    static var userName:String = UserDefaults.standard.string(forKey: "nickName") ?? "ERROR"
    static var userPP:String = UserDefaults.standard.string(forKey: "photoPath") ?? "https://ethikverein.de/wp-content/uploads/2020/12/anonym.png"
    static var userSol:Int = UserDefaults.standard.integer(forKey: "userSolCount") 
    static var userEntry:Int = UserDefaults.standard.integer(forKey: "userEntryCount")
    static var userEntryLike:Int = UserDefaults.standard.integer(forKey: "userEntryLikeCount")
    
}
struct CFont{
    static var AB:String = "Avenir-Black"
    static var AH:String = "Avenir-Heavy"
    static var AR:String = "Avenir-Roman"
    static var AM:String = "Avenir-Medium"
    static var ABO:String = "Avenir-Book"
    
    static var PL:String = "PingFangSC-Light"
    static var PR:String = "PingFangSC-Regular"
    static var PM:String = "PingFangSC-Medium"
    static var PS:String = "PingFangSC-Semibold"
}
