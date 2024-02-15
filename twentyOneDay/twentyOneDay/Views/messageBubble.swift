//
//  messageBubble.swift
//  twentyOneDay
//
//  Created by Burak on 8.08.2023.
//

import SwiftUI




struct messageBubble: View {
    @StateObject var viewModel = SolEntryViewModel()
    @StateObject var SolidManager = solidManager()
    var message:Message
    @State var x:Bool = false
    @Binding var UTDId:String
    @Binding var UIDShow:String
    @Binding var UTDBlocks:[String]
    @State var profileURL:String = ""
    @State var nickName:String = ""
    var solName:String
    var delete:() -> Void
    var body: some View {
        
        VStack(alignment: message.uid == UTDId ? .leading : .trailing){
            HStack(alignment:.top){
                ///değerlere göre photo kaybolsun mu yoksa gözüksün mü
                
                if(UIDShow != message.uid && message.uid != UTDId){
                    Menu{
                        NavigationLink(destination: visitProfile(UTDId: .constant(message.uid),url:.constant(profileURL))){
                            bubbleContextButton(text: "View Profile", image: "person.and.background.striped.horizontal", action: {})
                        }
                    }label: {
                        entryProfilePhoto(url: profileURL, onlySize: 35)
                    }
                    
                }else if(UIDShow == message.uid && message.uid != UTDId){
                    Circle().fill(.black.opacity(0)).frame(width: 35)
                }
                
                VStack(alignment: .leading,spacing:0) {
                    if(UIDShow != message.uid && message.uid != UTDId){///eğer nicki önceki mesajdaki nickle aynı değilse ve id si message'ın idsine eşit değilse nick ve id yazılarını getirt
                        
                        HStack(spacing: 5) { ///nick ve id
                            bubblePieceText(text: nickName, messageUID: message.uid, userUID: UTDId,bottomSpace: 0)
                            bubblePieceID(text: message.uid, messageUID: message.uid , userUID: UTDId)
                        }
                        
                    }
                    HStack(alignment: .bottom) { ///mesaj ve tarih
                        
                        bubblePieceText(text: message.text, messageUID: message.uid, userUID: UTDId,bottomSpace: 10)
                        bubblePieceDate(messageUID: message.uid, userUID: UTDId, time: message.time)
                        
                    }
                    
                }.padding(4).background(message.uid == UTDId ? color.mainHalf : .gray.opacity(0.15))
                    .contextMenu{
                        Section{
                            bubbleContextButton(text: "day \(message.dayString)", image: "", action: {})
                        }
                        bubbleContextButton(text: "copy", image: "rectangle.portrait.on.rectangle.portrait.angled", action: {
                            UIPasteboard.general.string = message.text
                            
                        })
                        
                        if(message.uid == UTDId){
                            bubbleContextButton(text: "delete from everyone", image: "trash", action: {
                                delete()
                                
                            })
                            
                        }else{
                            bubbleContextButton(text: "report", image: "exclamationmark.triangle", action: {
                                Task{
                                    do{
                                        try await SolidManager.sendPlaint(quiltyId: message.uid, quiltyEntryText: message.text, section: "\(solName)")
                                        x = true
                                    }catch{
                                        
                                    }
                                }
                                x = true
                            })
                            
                            
                            bubbleContextButton(text: "block", image: "person.crop.circle.badge.xmark", action: {
                                Task{
                                    do{
                                        try await viewModel.block(UTDId: UTDId, blockUID: message.uid)
                                        UTDBlocks.append(message.uid)
                                    }catch{
                                        
                                    }
                                }
                            })
                            if(UTDId == "ADMIN"){
                                bubbleContextButton(text: "ban", image: "circle", action: {
                                    Task{
                                        do{
                                           try await viewModel.banUser(userId: message.uid)
                                        }catch{
                                            
                                        }
                                    }
                                })
                            }
                            
                        }
                    }
                    .cornerRadius(12)
                
                
            }.frame(width: 300,alignment: message.uid == UTDId ? .trailing:.leading)
        
            
        }.frame(maxWidth: .infinity,alignment: message.uid == UTDId ? .trailing:.leading).padding(message.uid == UTDId ? .trailing : .leading).padding(.horizontal, 10).padding(.top,UIDShow != message.uid ? 10 : -4).onAppear{
            SolidManager.messageUserData(UID: message.uid){ (p,n) in
                if let p = p{
                    profileURL = p
                }
                if let n = n{
                    nickName = n
                }
            }
           
        }.alert(isPresented:$x) {
            Alert(title: Text("Report Submitted"), message: Text("\nwe will evaluate as soon as possible..."), dismissButton: .default(Text("OK.")) {
                    Task{
                        do{
                            try await viewModel.block(UTDId: UTDId, blockUID: message.uid)
                            UTDBlocks.append(message.uid)
                        }catch{
                            
                        }
                    }
                //self.presentationMode.wrappedValue.dismiss()
            })
        }
            
    }
    
}


struct bubbleContextButton:View {
    var text:String
    var image:String
    var action:() -> Void
    var body: some View {
        Button(action: {
            action()
        }){
            HStack{
                Text(text)
                Image(systemName: image)
            }
        }
    }
}

struct bubblePieceText: View {
    var text:String
    var messageUID:String
    var userUID:String
    var bottomSpace:CGFloat
    var body: some View {
        Text(text)
            .font(.custom(CFont.ABO, size: Size.sizeMedium))
            .foregroundColor(messageUID == userUID ? .white: color.dark)
            .padding(EdgeInsets(top: 10, leading: 8, bottom: bottomSpace, trailing: 0))
    }
}
struct bubblePieceID: View {
    var text:String
    var messageUID:String
    var userUID:String
    var body: some View {
        HStack(spacing:4){
            
            Image(systemName: "paperclip.badge.ellipsis").font(.system(size: Size.sizeSmall - 2))
            Text(String(text).prefix(8))
            
        }
        .font(.custom(CFont.ABO, size: Size.sizeMedium))
        .foregroundColor(messageUID == userUID ? color.white.opacity(0.3) : color.dark.opacity(0.25))
        .padding(EdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 0))
    }
}
struct bubblePieceDate:View {
    
    @ObservedObject var messagesManagers = messagesManager()
    var messageUID:String
    var userUID:String
    var time:Date
    var body: some View {
        Text("\(messagesManagers.messageTime(date: time))").font(.custom(CFont.AH, size: Size.sizeSmall)).foregroundColor(messageUID == userUID ? color.white.opacity(0.45) : color.dark.opacity(0.25)).padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 6))
    }
}
struct visitProfile:View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var MessagesManager = messagesManager()
    
    @State var mustDoEntry:Int = 1
    @State var levelEntry:Int = 1
    @State var totalEntryForMath:Int = 1
    
    @State var totalEntryLikeForMath:Int = 1
    @State var levelEntryLike:Int = 1
    @State var mustDoEntryLike:Int = 1
    
    
    @State var UTDEntry:Int = 0
    @State var UTDEntryLike:Int = 0
    @State var UTDSol:Int = 0

    @State var UTDNick:String = "a"
    @Binding var UTDId:String
    @Binding var url:String
    var body: some View {
        
        NavigationStack{
            ZStack{
                List{
                     Section(header:Text("Profile")){
                         HStack{
                             Spacer()
                            
                                 entryProfilePhoto(url: url, onlySize: 120)
                                
                             
                             
                             
                             
                             Spacer()
                         }.padding()
                         HStack{
                             Image(systemName: "person.and.background.dotted")
                             Text(UTDNick).font(.custom(CFont.ABO, size: Size.sizeMedium)).fontWeight(.semibold).foregroundColor(color.dark)
                             
                             
                         }.padding()
                             .foregroundStyle(color.dark)
                         
                         HStack {
                             Image(systemName: "rectangle.dashed.and.paperclip")
                             Text(UTDId).font(.custom("Avenir-Roman", size: Size.sizeMedium))
                             
                         }.padding().fontWeight(.regular).foregroundColor(color.dark.opacity(0.5))
                         
                     }
                     Section(header:Text("")){
                         
                         VStack(alignment:.leading,spacing: 35){
                             
                             Text("ACHIEVEMENTS").font(.custom(CFont.AB, size: Size.sizeUltraLarge)).foregroundStyle(color.dark)

                             VStack(alignment:.leading,spacing:60){
                                 if(levelEntry > 1){
                                     numberRCordsVisit(level: $levelEntry, UTD: $UTDEntry, title: "Helpful",image: "yardimsever",count: UTDEntry,color1: color.mainCounter, color2:color.dark)
                                 }
                                 if(levelEntryLike > 1){
                                     numberRCordsVisit(level: $levelEntryLike, UTD: $UTDEntryLike, title: "Like Magnet", image: "begenimagnet",count:UTDEntryLike, color1: .red, color2: color.main)
                                 }
                                 
                                 if(UTDSol > 0){
                                     numberRCordsVisit(level: .constant(UTDSol > 0 ? 5 : 1), UTD: $UTDSol, title: "Renaissance", image: "yenidendogus",count:UTDSol, color1: color.mainCounter, color2: .red)
                                 }
                             
                             }
                         }
                         .padding(.vertical,20)

                     }
                     
                 }.listStyle(.sidebar)

            }.toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        HStack{
                            Image(systemName: "arrow.left")
                        }.font(.custom(CFont.ABO, size: Size.sizeLarge))
                            .foregroundStyle(color.main)
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
        .task {
            do{
                try await MessagesManager.loadVisitedProfile(UID: UTDId)
                if let visitedOnlyProfile = MessagesManager.vProfile{
                    UTDNick = visitedOnlyProfile.nickName!
                    UTDSol = visitedOnlyProfile.profileSol!
                    UTDEntry = visitedOnlyProfile.profileEntry!
                    UTDEntryLike = visitedOnlyProfile.profileEntryLike!
                
                }
                
            }catch{
                
            }
            mustDoEntry = missionMathEntry(entry: UTDEntry).0
            levelEntry = missionMathEntry(entry: UTDEntry).1
            totalEntryForMath = missionMathEntry(entry: UTDEntry).2
            
            mustDoEntryLike = missionMathEntryLike(entry: UTDEntryLike).0
            levelEntryLike = missionMathEntryLike(entry: UTDEntryLike).1
            totalEntryLikeForMath = missionMathEntryLike(entry: UTDEntryLike).2
        }
    }
}
#Preview{(visitProfile(UTDId: .constant("1234"),url: .constant("12345")))}

struct numberRCordsVisit: View {
    @Binding var level:Int
    @Binding var UTD:Int
    
    var title:String
    var image:String
    var count:Int
    var color1:Color
    var color2:Color

    
    var body: some View{
        
        HStack(spacing: 15){
            profileSuccessImage(image: image, level: 1)
            
            VStack(alignment:.leading,spacing:12){
                Text(title).fontWeight(.heavy)
                HStack{
                    ForEach(1...level,id: \.self){ x in
                        if(x != 1){
                            Image(systemName: "star.fill").font(.system(size: Size.sizeLarge)).foregroundStyle(color.mainCounter).shadow(radius: 1)
                        }
                    }
                }
                Text("\(count)").font(.custom(CFont.AB, size: Size.sizeLarge)).opacity(0.3)
                
                
            }.font(.custom(CFont.ABO, size: Size.sizeMedium))
            
        }.foregroundColor(color.dark)
    }
}
