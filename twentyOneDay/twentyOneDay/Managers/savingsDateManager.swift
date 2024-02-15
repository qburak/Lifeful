import Foundation

class savingsDateManager:ObservableObject{
    
    func dateMath(date:Date,array:Array<Int>) -> (Int,Int){
        
        let dateFormatter = DateFormatter() // DateFormatter sınıfından bir nesne oluşturuyoruz
        dateFormatter.dateFormat = "dd.MM.yyyy" // Tarih formatını belirliyoruz
        let date1 = dateFormatter.string(from: date) // Başlangıç tarihini belirliyoruz ve DateFormatter nesnesiyle formatlıyoruz
        let date2 = Date() // Şu anki tarihi alıyoruz

        let calendar = Calendar.current
           let components = calendar.dateComponents([.day], from: dateFormatter.date(from: date1)!, to: date2)

           var count = 0
           var date = dateFormatter.date(from: date1)!
            
        array.forEach{ x in
            while date <= Date() {
                let weekday = calendar.component(.weekday, from: date)
                
                if array.contains(weekday){
                    count += 1
                }
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
           print("Toplam gün sayısı: \(components.day!)")
           print("Toplam cuma sayısı: \(count)")
        
        return (components.day ?? 0, count)
    }
    func dayMath(date:Date) -> Int{
        let dateFormatter = DateFormatter() // DateFormatter sınıfından bir nesne oluşturuyoruz
        dateFormatter.dateFormat = "dd.MM.yyyy" // Tarih formatını belirliyoruz
        let date1 = dateFormatter.string(from: date) // Başlangıç tarihini belirliyoruz ve DateFormatter nesnesiyle formatlıyoruz
        let date2 = Date() // Şu anki tarihi alıyoruz

        let calendar = Calendar.current
           let components = calendar.dateComponents([.day], from: dateFormatter.date(from: date1)!, to: date2)

           var count = 0
           var date = dateFormatter.date(from: date1)!
        return components.day ?? 0

    }
}
