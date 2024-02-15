
//  Created by Burak on 9.12.2023.


import SwiftUI
import Charts


struct dailyPage: View {
    @StateObject var entry = entryManager()
    @Binding var day:Int
    var emojies:[String] = ["😁","😃","🙂","🙁","😔","😫"]
    @State var cEmoji:String = "😶"
    @State var percentUS:Int = 0
    @Binding var userEmojies:[String]
    @State var UTDEmojies:[String] = []
    @Binding var urlPhoto:String
    @Binding var sol:String
    @Binding var UID:String
    @Binding var ID:String
    @Binding var stageD:adictionStage
    @Binding var stage:Int
    @Binding var mControl:Bool
    
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                VStack(spacing: 40){
                    VStack{
                        dailyPhoto(url: urlPhoto, onlySize: 100)
                        dailyText(title: "\(sol) Addiction", subTitle: "Daily Commitment Check")
                    }
                    VStack{
                        HStack(spacing:5){
                            Image(systemName: "circle.dashed.inset.filled").font(.system(size: Size.sizeUltraLarge)
                                .weight(.thin)
                            ).foregroundStyle(color.dark).overlay{
                                Text("\(stage)").foregroundStyle(.white)
                            }
                            dailyBarView(percent: CGFloat(percentUS))
                            Image(systemName: "circle.dashed.inset.filled").font(.system(size: Size.sizeUltraLarge)
                                                                                 
                            ).fontWeight(.thin).foregroundStyle(color.main).overlay{
                                Text("\(stage + 1)").foregroundStyle(color.white)
                            }
                            
                        }
                        VStack{
                            dailyText2(title: "\(stageD.leftDay - day) days left", subTitle: "for the new stage", opacity: 0.5)
                        }
                    }
                    Spacer()
                    VStack(spacing:10){
                        
                        dailyText2(title: "how do you feeling", subTitle: "choose ur mood", opacity: 0.5)
                        
                        Menu{
                            ForEach(0...emojies.count - 1,id:\.self){ x in
                                Button(action: {
                                    cEmoji = emojies[x]
                                }){
                                    Text("\(emojies[x])")
                                }
                            }
                        }label: {
                            Circle().fill(.white).frame(width: geo.size.width / 9).shadow(radius: 2).overlay{
                                Text(cEmoji).font(.system(size: 30))

                            }
                                
                        }
                    }
                    
                    Spacer()

                    Button(action: {
                        UTDEmojies.append(cEmoji)
                    }){
                        NavigationLink(destination: dailySecondPage(userEmojies: $UTDEmojies, selectedEmoji: $cEmoji,UID:$UID,ID:$ID,mControl:$mControl)){
                            dailyButton(width: geo.size.width / 2,height: geo.size.height / 15.5, text: "I Am Committed",Bcolor: cEmoji == "😶" ? .gray.opacity(0.5) : color.main)
                        }
                    }.disabled(cEmoji == "😶")
                        
                 
                 
                }.onAppear{
                    cEmoji = "😶"
                    UTDEmojies = userEmojies
                    withAnimation(.easeInOut(duration: 2.4)){
                        percentUS = ((100 / stageD.leftDay) * day)
                       // percentUS = (100 / (entry.entryStageMath(actualDay: day).1 - entry.entryStageMath(actualDay: day).3 + 1)) * (day - entry.entryStageMath(actualDay: day).3)
                    }
                }
            }
        }
    }
}

struct dailySecondPage: View {
    @StateObject var SolidManager = solidManager()
    let fixedEmojis = ["😁", "😃", "🙂", "🙁", "😔", "😫"]
    @State var emojiData: [String: Double] = [:]
    @Binding var userEmojies: [String]
    @State var mostlyEmoji:String = ""
    @Binding var selectedEmoji:String
    @State var moodsControl:Bool = false
    @Binding var UID:String
    @Binding var ID:String
    @Binding var mControl:Bool
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                VStack{
                    dailyText(title: "Total Moods Chart", subTitle: "")
                    
                    dailyChart(emojiData: $emojiData, userEmojies: $userEmojies)
                    
                    Spacer()
                    
                    VStack(spacing:25){
                        
                        HStack(spacing:45){
                            
                            moodsLast(mood: selectedEmoji, text: "Today",height: geo.size.height / 10,width: geo.size.width / 4)
                            
                            if(mostlyEmoji != ""){
                                moodsLast(mood: mostlyEmoji, text: "Mostly",height: geo.size.height / 10,width: geo.size.width  / 4)
                            }
                            
                        }
                        
                        emojiComment(selectedEmoji: $selectedEmoji, mostSelectedEmoji: $mostlyEmoji)
                    }
                    .padding(.horizontal,geo.size.width / 8)
                    .multilineTextAlignment(.center)
                    
                    
                    Spacer()
                    Button(action: {
                        moodsControl = true
                        Task{
                            do{
                                try await SolidManager.setupMood(UID: UID, id: ID, Date: Date(), Moods: userEmojies)
                                mControl = false
                            }catch{
                                
                            }
                        }
                    }){
                        
                            dailyButton(width: geo.size.width/2, height: geo.size.height / 15.5, text: "continue",Bcolor: color.main)
                        
                    }.disabled(moodsControl)
                }
                
            }.onAppear {
                userEmojies.append(selectedEmoji)
                if let mostly = userEmojies.reduce(into: [:], { counts, emoji in
                    counts[emoji, default: 0] += 1
                }).filter({ $0.value > 1 }).max(by: { $0.value < $1.value })?.key {
                    mostlyEmoji = mostly
                } else {
                    // Koşul sağlanmazsa burada istediğiniz kodu çalıştırın
                    // Örneğin: mostlyEmoji'yi bir varsayılan değere ayarlamak
                    mostlyEmoji = ""
                }
            }.navigationBarBackButtonHidden()
        }
    }
}
struct dailyChart: View {
    let fix = ["😁", "😃", "🙂", "🙁", "😔", "😫"]
    @Binding var emojiData: [String:Double]
    @Binding var userEmojies:[String]
    
    var body: some View {
        Chart {
            ForEach(emojiData.keys.sorted(), id: \.self) { emoji in
                if let amount = emojiData[emoji] {
                    
                    SectorMark(
                        angle: .value("Emoji", amount),innerRadius: .ratio(0.6), outerRadius: .ratio(0.85),
                        angularInset: 1.5
                    )
                    .cornerRadius(6)
                    .shadow(radius: 3)
                    .foregroundStyle(by: .value("Emojies", emoji))
                }
            }
        }
        .chartLegend(alignment: .centerFirstTextBaseline)
        .frame(height: 300)
        .cornerRadius(20)
        .onAppear{
            calculateEmojiData()
        }
    }
    
    func calculateEmojiData() {

        var counts = [String: Double]()
        for emoji in fix {
            counts[emoji] = Double(userEmojies.filter { $0 == emoji }.count)
        }
        emojiData = counts
    }
}
struct moodsLast: View {
    var mood:String
    var text:String
    var height:CGFloat
    var width:CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 20).fill(.white).frame(width:width,height: height).shadow(radius: 2).overlay{
            VStack(spacing:0){
                Text(text).foregroundStyle(color.dark)
                Text("\(mood)")
            }
        }
        .font(.custom(CFont.AH, size: Size.sizeLarge))
        .foregroundStyle(color.mainCounter)
    
            
    }
}

struct emojiComment: View {
    @State var comment:String = ""
    @Binding var selectedEmoji:String
    @Binding var mostSelectedEmoji:String
    let emojiComments: [String: [String: String]] = [
        "🙂": [
            "🙂": "You generally feel balanced and well, which shows that you have a strong attitude towards the ups and downs of life. Maintaining this balanced attitude will be a great support for you in your fight against addiction.",
            "😃": "You don't always have to be on top. Feeling calmer today will help you experience different aspects of life and support you in this process.",
            "😁": "Although you're often very happy, it's also nice to feel a simpler happiness today. Finding happiness in the small details of life is an important step in supporting your fight against addiction.",
            "🙁": "It's normal to feel sad sometimes, but it's good that you're feeling better today. Take care of yourself and try to maintain this optimistic feeling.",
            "😔": "Life has its difficult moments, but it is encouraging to feel better today. Celebrating these positive moments contributes to your healing process.",
            "😫": "You may have been through difficult times, but feeling a little better today shows your strength and resilience. This is an important part of the fight against addiction.",
            "":"Choosing this emoji shows that you usually feel calm and balanced. This emotional balance is very important when you are struggling with addiction. Focus on maintaining your peace of mind and utilising these calm moments with supportive activities."
        ],
        "😃": [
            "🙂": "It's great that you feel even happier today, when you are usually in a balanced emotional state. Maintaining this joy and energy will give you strength in your fight against addiction.",
            "😃": "Your consistently high level of happiness is impressive. Keep spreading this energy to the people around you, it will have a positive effect on you and your environment.",
            "😁": "At a time when you usually feel at the peak of your life, it's nice to be at the peak of happiness today. Feeling this positivity at every moment will support your fight against addiction.",
            "🙁": "It's normal to feel low sometimes, but it's encouraging that you're so happy today. Reward yourself with this happiness, this is an important step on your way to fight addiction.",
            "😔": "Sometimes there are moments when you feel sad, but the fact that you feel great today is a great achievement. Celebrate this change, this is an important step towards recovery.",
            "😫": "You may have been through difficult times, but your happiness today shows your resilience and joy for life. This can inspire you in your fight against addiction.",
            "":"Feeling happy today is an important source of energy in the fight against addiction. Think about what you can do to maintain and sustain this positive energy."
        ],
        "😁": [
            "🙂": "Usually in a balanced mood, today you feel at your peak. Enjoy these special moments, they will give you motivation to fight addiction.",
            "😃": "Although you are often happy, today you feel even more energised and full of life. Sharing and spreading this energy will help you in your recovery.",
            "😁": "It is rare and precious to have such a high level of energy all the time. Maintaining this enthusiasm and joie de vivre will strengthen your fight against addiction.",
            "🙁": "Although there are times when you feel low, it is a great achievement that you feel on top today. Celebrate this change, it is an important step in the fight against addiction.",
            "😔": "Although you have experienced sadness in some periods of your life, today you are in a state of extraordinary happiness. Treasure these moments, it shows your strength in the fight against addiction.",
            "😫": "It's really impressive to reach such a high level of happiness after difficult times. This is your strength and resilience, which will inspire you to fight addiction.",
            "":"You are having a very happy day, which can increase your motivation in the fight against addiction. Find out how you can maintain this enthusiasm and energy."
        ],
        "🙁": [
            "🙂": "It is normal to feel a little sad today after a day when you usually feel balanced. Accepting these feelings will help you to understand yourself better and give you strength in the fight against addiction.",
            "😃": "Even though you are happy most of the time, it is completely normal to feel a little low today. Be kind to yourself and try to understand these feelings, they will support you in this process.",
            "😁": "It's not possible to feel on top all the time. Feeling a little low today is a natural part of life. Accepting yourself this way is part of the fight against addiction.",
            "🙁": "It can be difficult to experience these feelings often, but every day is a new beginning. Give yourself time and be patient on your journey of recovery, it shows your strength.",
            "😔": "It is normal to feel sad from time to time. Feeling this way today can be an opportunity to understand your feelings and this will help you in the healing process.",
            "😫": "Even after the most difficult times, expressing your feelings is a powerful step. Feel free to express yourself and accept these feelings, this is part of your fight against addiction.",
            "":"Feeling sad today can be a difficult part of the struggle. Every feeling is temporary, and tomorrow can be a better day. Be kind to yourself."
        ],
        "😔": [
            "🙂": "It is completely normal to feel a little low today, at a time when you usually feel balanced. Accepting and understanding these feelings is important to get to know yourself better and will help you in the fight against addiction.",
            "😃": "Although you are mostly happy, feeling a little sad today is part of experiencing different aspects of life. Experiencing these feelings can guide you through the recovery process.",
            "😁": "Being too happy all the time can sometimes be exhausting. Feeling a little low today can be a sign that you need to take more time for yourself, and this is an important step on the road to addiction recovery.",
            "🙁": "It's normal to feel sad from time to time, but remember that every day is a new beginning. Be kind to yourself and focus on your journey of recovery, it will give you strength in the process.",
            "😔": "Feeling sad often can be challenging. However, understanding and accepting these feelings helps you to get to know yourself better and is part of the fight against addiction.",
            "😫": "You may be going through a difficult time, but remember that these feelings are temporary. Give yourself time and take small steps, this is an important step on your road to recovery.",
            "":"Feeling sad is a natural part of the healing journey. Accepting and understanding these feelings will help you in this process."
        ],
        "😫": [
            "🙂": "It can be difficult to feel so low today, when you usually feel balanced. Remember that difficult times are temporary and this too will pass. These difficult times will make you stronger in your fight against addiction.",
            "😃": "Although you are happy most of the time, sometimes you may have very difficult moments. Experiencing and accepting these feelings is part of the healing process and will make you stronger.",
            "😁": "After having consistently high energy levels, it can feel heavy to have such a difficult day. Be kind to yourself and don't hesitate to seek support, it will help you in your fight against addiction.",
            "🙁": "It can be sad to feel even worse today when you are already having a hard time. But there is always hope and tomorrow can be a better day. This hope will give you strength for recovery.",
            "😔": "Sometimes feeling sad can be even heavier these days. Be kind to yourself and remember to take care of yourself in these difficult times, this is important for your recovery.",
            "😫": "It can be exhausting to constantly struggle with difficulties. But with each challenge you get stronger. Express yourself and seek support, this will help you on your way to overcoming addiction.",
            "":"Feeling very down today can be challenging, but experiencing and expressing these feelings is an important step in the healing process. Give yourself time and take small steps."
        ]
    ]
    
    var body: some View {
        Text("\(comment)")
            .font(.custom(CFont.ABO, size: Size.sizeLarge))
            .foregroundStyle(color.dark)
        
            .onAppear{
                comment = emojiComments[selectedEmoji]?[mostSelectedEmoji] ?? "No comment available."
            }
    }
    
    
}






#Preview {
    dailyPage(day: .constant(1),userEmojies: .constant(["🙂","😁","😔"]), urlPhoto: .constant("https://firebasestorage.googleapis.com/v0/b/days-e0355.appspot.com/o/solidPictures%2Frealitytv.jpg?alt=media&token=25972607-5088-4e37-afe5-82d00ec14b17"),sol: .constant("Reality TV"),UID: .constant(""),ID: .constant(""),stageD: .constant(.awareness),stage: .constant(1),mControl:.constant(false))
}
struct dailyButton: View {
    var width:CGFloat
    var height:CGFloat
    var text:String
    var Bcolor:Color
    
    var body: some View {
       
            Text(text)
                .frame(width: width,height: height)
                .font(.custom(CFont.AB, size: Size.sizeLarge))
                .fontWeight(.bold)
                .foregroundStyle(color.white)
                .background(Bcolor)
                .cornerRadius(15)
                .padding(.bottom, 1)
     
    }
}

struct dailyBarView: View {
    var width:CGFloat = 200
    var height:CGFloat = 6
    var percent:CGFloat = 40
    var color1:Color = color.dark
    var color2:Color = color.main
    
    var body: some View {
        
        ZStack(alignment: .leading){
            let multiplier = width / 100
            RoundedRectangle(cornerRadius: height,style: .continuous).frame(width:width,height: height).foregroundColor(Color.black.opacity(0.06))
            
            RoundedRectangle(cornerRadius: height,style: .continuous).frame(width: percent * multiplier,height: height).background(
                LinearGradient(gradient: Gradient(colors: [color1,color2]), startPoint: .leading, endPoint: .trailing).clipShape(RoundedRectangle(cornerRadius: height,style: .continuous))
            ).foregroundColor(.clear)
            
            
        }
    }
}
struct dailyPhoto:View{

    var url:String
    var onlySize:CGFloat
    
    var body: some View{
        ZStack{
            AsyncImage(url: URL(string: url)){ image in
                image.resizable().scaledToFill().frame(width:onlySize,height: onlySize).cornerRadius(onlySize/5).shadow(radius: 4)
            }placeholder: {
                RoundedRectangle(cornerRadius: onlySize/5).fill(.white).frame(width: onlySize,height: onlySize).shadow(radius: 4).overlay{
                    ProgressView().frame(width: onlySize,height: onlySize)
                }
                
                   
                
            }
        }
    }
}
struct dailyText: View {
    var title:String
    var subTitle:String
    @State var popover:Bool = false
    var body: some View {
        VStack(spacing:15){
        
            VStack{
                Text(title).font(.custom(CFont.ABO, size: Size.sizeUltraLarge))
                   
                
                Text(subTitle).font(.custom(CFont.ABO, size: Size.sizeLarge))
            }
        }.foregroundStyle(color.dark)
            
    }
}
struct dailyText2: View {
    var title:String
    var subTitle:String
    var opacity:CGFloat
    @State var popover:Bool = false
    var body: some View {
        VStack(spacing:15){
        
            VStack{
                Text(title).font(.custom(CFont.ABO, size: Size.sizeLarge))
                   
                
                Text(subTitle).font(.custom(CFont.ABO, size: Size.sizeLarge)).opacity(opacity)
            }
        }.foregroundStyle(color.dark)
            .fontWeight(.semibold)
            
    }
}
