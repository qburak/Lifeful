import SwiftUI

struct motivationPage: View {
    @State var isScalingHalfinHalf:Bool = true
    @State var changer:Bool = false
    @State var isScaling:Bool = false
    @Binding var mDay:Int
    @Binding var mStageD:adictionStage
    @Binding var mStage:Int
    @Binding var motivationRemainingDay:Int
    @Binding var mWhy:String
    @State var motivationSpecial:[String] = [""]
    @State var motivationTitleAreas:[String] = ["Sana Özel","Öneriler","Motivasyon Cümleleri"]
    @State var motivationEmojis:[String] = ["🏆","💪","🚀"]
    @Binding var motivationTitleNumber:Int
    @State var motivationSentenceArray = [LocalizedStringKey]()
    @State var moSenRandom:Int = 1
    @State var offerRandom:Int = 1
    @State var emojiRandom:Int = 0
    @State var textScale:Bool = true
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack(alignment: .top){
                    Spacer()
                    progressBarView(width: 300,percent:CGFloat(0),color1:Color("N-Color02"),color2:Color("N-Color03")).padding(EdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 30))
                    Spacer()
                }
                
                
                
                    
                    
                    switch motivationTitleNumber{
                    case 0:
                        
                        TabView(selection: $offerRandom) {
                            ForEach(1...19,id: \.self) { x in
                                
                                VStack {
                                    customOfferV2Text(updateQuestion: "offerTitle-\(x)",exQuestionsArray: "offer-\(x)")
                                    Spacer()
                                    customOfferSolV2Text(solitions: "offerDescription-\(x)")
                                    Spacer()
                                }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)).background(.white).tag(x).onTapGesture {
                                    withAnimation{
                                        if( offerRandom < 19){
                                            offerRandom += 1
                                        }else{
                                            offerRandom = 1
                                        }
                                    }
                                }
                            }
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                    case 1:
                        let localizedString = NSLocalizedString("moSentence-\(moSenRandom)", comment: "")
                        customSentencesText(title: .constant(motivationEmojis[emojiRandom]), text: .constant(localizedString), emoji: $emojiRandom, isScaling: $isScaling).padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)).background(.white).onTapGesture {
                            if(moSenRandom < 100){
                                moSenRandom += 1
                            }else{
                                moSenRandom = 1
                            }
                            isScaling = true
                            withAnimation(.spring(response: 0.3,dampingFraction: 0.3)){
                                isScaling = false
                                emojiRandom = Int.random(in: 0...2)

                            }
                        }
                        
                    case 2:
                        
                        customSpecialText(title: .constant(mStageD.title), text: .constant(NSLocalizedString(mStageD.day,comment: "")), middleText: .constant("[ \(mDay). Gün ]   [ \(mStage). Evre ]"), textWhy: .constant("\(mWhy)"),changer: $changer,isScaling: $isScaling).padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)).onTapGesture {
                            withAnimation {
                                changer.toggle()
                            }
                        }
                        
                    default:
                        Text("ERROR")
                    }
                    
                    
                
                
                

            }.background(Color("N-Color00")).onAppear(){
                
                offerRandom = Int.random(in: 1..<20)
                moSenRandom = Int.random(in: 1..<101)
               
                motivationSpecial = ["bu kadar günün kaldı\(motivationRemainingDay), pes etme!!!"]
        }
        
    }
}

struct motivationPage_Previews: PreviewProvider {
    static var previews: some View {
        motivationPage(mDay: .constant(8),mStageD: .constant(.awareness), mStage: .constant(3), motivationRemainingDay: .constant(6), mWhy: .constant("nerden bileceksiniz"), motivationTitleNumber: .constant(2))
    }
}
struct customSentencesText:View{
    @Binding var title:String
    @Binding var text:String
    @Binding var emoji:Int
    @Binding var isScaling:Bool
    
    var body: some View{
        
        VStack(alignment: .center,spacing: 10) {
            
            Text(title).font(.custom("Avenir-Roman", size: Size.sizeUltraLarge)).fontWeight(.black).foregroundColor(Color("N-Color03")).multilineTextAlignment(.center)
            
            Spacer()
            
  
                
                HStack{
                    
                    Image(systemName: "quote.opening").font(.system(size: Size.sizeUltraLarge)).foregroundColor(Color("N-Color0303").opacity(1)).padding(.bottom,16)
                    Spacer()
                }.padding(.leading,-4)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString(text, comment: "")).font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundColor(.black.opacity(0.6)).fontWeight(.black)
                
            }.frame(maxWidth: .infinity)
         
                
                HStack{
                    Spacer()
                    Image(systemName: "quote.closing").font(.system(size: Size.sizeUltraLarge)).foregroundColor(Color("N-Color04").opacity(0.3))
                }
            
          
            Spacer()
            
        }.scaleEffect(isScaling ? 0.5 : 1).background(.clear)
    }
}

struct customOfferV2Text:View{
    var updateQuestion:String = "******"
    var exQuestionsArray:String = "******"

    
    var body: some View{
        HStack {
            Spacer()
            VStack(alignment: .leading,spacing: 20) {
                Text(NSLocalizedString(updateQuestion, comment: "")).font(.custom("AvenirNext-Heavy", size: Size.sizeLarge)).foregroundColor(.black.opacity(0.6)).fontWeight(.black).lineLimit(1)
                
                Text(NSLocalizedString(exQuestionsArray, comment: "")).font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundColor(.black.opacity(0.3))
                Divider()
            }
            Spacer()
        }
    }
}
struct customOfferSolV2Text:View{
    var solitions:String = "******"
    

    
    var body: some View{
        HStack() {
            
            Text(NSLocalizedString(solitions, comment: "")).font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundColor(.black.opacity(0.6)).fontWeight(.black)
            Spacer()
        }
    }
}

struct customSpecialText:View{
    @Binding var title:String
    @Binding var text:String
    @Binding var middleText:String
    @Binding var textWhy:String
    @Binding var changer:Bool
    
    @Binding var isScaling:Bool
    var body: some View{
        VStack(alignment: .center,spacing: 0) {
            VStack {
                HStack {
                    Text(!changer ? title : "Hatırla").font(.custom("AvenirNext-Heavy", size: Size.sizeLarge)).fontWeight(.black).foregroundColor(.black.opacity(0.6)).multilineTextAlignment(.center)
                    Text(!changer ? middleText : "that's why you started the struggle").font(.custom("Avenir-Roman", size: Size.sizeMedium)).fontWeight(.black).foregroundColor(Color("N-Color04").opacity(0.24)).multilineTextAlignment(.center)
                }
                Divider()
            }
            
            VStack(alignment: .leading) {
                ScrollView {
                    Text(!changer ? text : textWhy).font(.custom("Avenir-Roman", size: Size.sizeLarge)).multilineTextAlignment(.leading).padding(.top,20).onTapGesture {
                        
                    }
                }
            }.frame(maxWidth: .infinity).background()
            
            Spacer()
        }.scaleEffect(isScaling ? 0.5 : 1).background(.clear)
    }
}
