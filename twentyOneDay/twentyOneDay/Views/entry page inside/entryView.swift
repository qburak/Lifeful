//
//  entryView.swift
//  twentyOneDay
//
//  Created by Burak on 14.08.2023.
//

import SwiftUI

struct entryView: View {

    @State var sheetHeight:CGFloat = .zero

    @StateObject var viewModel = SolEntryViewModel()
    @StateObject var SolidManager = solidManager()
    var entry:SolEntry
    @State var url:String = ""
    @State var name:String = ""
    @Binding var userId:String
    @Binding var UTDId:String
    @Binding var UTDBlock:[String]
    @State var EntryManager = entryManager()
    @State var ffv:CGFloat = 70
    @State var didLike:Bool = false
    @State var sAlert:Bool = false
    var body: some View {
        ZStack {
            VStack(spacing:0){
                HStack(alignment: .top,spacing: 20){
                    ZStack{
                        NavigationLink(destination: visitProfile(UTDId: .constant(entry.userid), url: $url)){
                            
                            
                            entryProfilePhoto(url: url, onlySize: 30)
                        }
                        
                        
                        
                        Text(entry.emoji).font(.system(size: Size.sizeLarge - 4)).transformEffect(.init(translationX: -12, y: -12)).opacity(0.7)
                        
                        
                    }
                    
                    
                    
                    
                    
                    VStack(alignment: .leading,spacing: 20){
                        HStack(spacing:12){
                            entryUserName(name: name)
                            HStack(spacing: 2){
                                Image(systemName: "paperclip.circle")
                                    .foregroundStyle(color.dark)
                                    .font(.system(size: Size.sizeMedium - 1))
                                entryId(id: userId)
                            }.opacity(0.4)
                            
                        }.padding(.top,4)
                        
                        entryText(text: entry.text)
                        
                        HStack{
                            entryDate(time: entry.time)
                            Spacer()
                            
                            
                            
                            entryLikeButton(didLike: didLike, like: entry.likes, action: {
                                if(!didLike){
                                    viewModel.likeEntry(entry: entry, userId: UTDId)
                                }else{
                                    viewModel.unLikeEntry(entry: entry, userId: UTDId)
                                }
                                
                            })
                            
                            entryMoreButton(UTDId:UTDId,own: entry.userid == UTDId, day:entry.day,title: entry.sol,plaintAction: {
                                Task{
                                    do{
                                        try await SolidManager.sendPlaint(quiltyId: entry.userid, quiltyEntryText: entry.text, section: "entry-\(entry.sol)")
                                        sAlert = true
                                    }catch{
                                        
                                    }
                                }
                            }, deleteAction: {
                                Task{
                                    do{
                                        try await viewModel.deleteEntryHide(sol: entry.sol, text: entry.text, UID: UTDId, Date: Date(), Name: name)
                                        viewModel.deleteEntry(entry: entry, userId: UTDId)
                                        
                                    }catch{
                                        
                                    }
                                }
                            }, blockAction: {
                                Task{
                                    do{
                                        try await viewModel.block(UTDId: UTDId, blockUID: entry.userid)
                                        UTDBlock.append(entry.userid)
                                        
                                    }catch{
                                        
                                    }
                                }
                            }, banAction: {
                                Task{
                                    do{
                                        try await viewModel.banUser(userId: userId)
                                    }catch{
                                        
                                    }
                                }
                            })
                            
                        }.opacity(1)
                        
                    }.frame(maxWidth: .infinity).shadow(radius: 0)
                        .background(.clear)
                        .onAppear{
                            Task{
                                
                                viewModel.didUserLike(entry: entry, userId: UTDId, completion: { x in
                                    didLike = x
                                })
                                
                                viewModel.fetchProfileData(for: userId) { result in
                                    switch result {
                                    case .success(let profileData):
                                        print("AXA")
                                        url = profileData.photoPath ?? "a"
                                        name = profileData.nickName ?? "aaa"
                                        // Diğer verilere erişim...
                                    case .failure(let error):
                                        print("Veri çekme hatası: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    
                }.padding(.horizontal,20).background(.white)
                Divider()
            }
        }
        .alert(isPresented: $sAlert) {
            Alert(title: Text("Report Submitted"), message: Text("\nwe will evaluate as soon as possible..."), dismissButton: .default(Text("OK.")) {
                Task{
                    do{
                        try await viewModel.block(UTDId: UTDId, blockUID: entry.userid)
                        UTDBlock.append(entry.userid)
                        
                    }catch{
                        
                    }
                }
            })
        }
    }
}

struct entryView_Previews: PreviewProvider {
    static var previews: some View {
        entryView(entry: SolEntry(id: "a", text: "in pellentesque massa placerat duis ultricies lacus sed turpis tincidunt id aliquet risus feugiat in ante metus dictum at tempor commodo ullamcorper a lacus.", day: 0, sol: "Instagram", stage: 0, time: Date(), emoji: "🙂", userid: "", likes: 0), userId: .constant("1234"), UTDId: .constant("12345"), UTDBlock: .constant([]))
    }
}
struct entryProfilePhoto:View{

    var url:String
    var onlySize:CGFloat
    
    var body: some View{
        ZStack{
            AsyncImage(url: URL(string: url)){ image in
                image.resizable().scaledToFill().frame(width:onlySize,height: onlySize).cornerRadius(onlySize/2).shadow(radius: 4)
            }placeholder: {
                Circle().fill(.white).frame(width: onlySize,height: onlySize).shadow(radius: 4).overlay{
                    ProgressView().frame(width: onlySize,height: onlySize)
                }
            }

        }
    }
}
struct entryUserName:View{
    var name:String
    
    var body: some View{
        Text(name).font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundColor(color.dark)
    }
}
struct entryId:View{
    var id:String
    
    var body: some View{
        Text(String(id).prefix(10)).font(.custom(CFont.ABO, size: Size.sizeMedium - 2)).foregroundColor(color.dark)
    }
}
struct entryText:View{
    var text:String
    var body: some View{
        Text(text)
            .font(.custom("Avenir-Roman", size: Size.sizeMedium)).fontWeight(.light)
            .foregroundColor(color.dark)
       
    }
}

struct entryMoreButton:View{
    var UTDId:String
    var own:Bool
    var day:Int
    var title:String
    var plaintAction:() -> Void
    var deleteAction:() -> Void
    var blockAction:() -> Void
    var banAction:() -> Void

    var body: some View{
        
        Menu{
            Text("Day \(day)")
            
            Text("\(title) Addiction")
            
            if !own{
                Button(action: {
                    plaintAction()
                }){
                    Text("report")
                    Image(systemName: "exclamationmark.triangle")
                }
                Button(action: {
                    blockAction()
                }){
                    Text("block")
                    Image(systemName: "person.crop.circle.badge.xmark")
                }
                if(UTDId == "ADMIN"){
                    Button(action: {
                        banAction()
                    }){
                        Text("ban")
                        
                    }
                }
            }
            else {
                Button(action: {
                    deleteAction()
                }){
                    HStack{
                        Text("delete")
                        Image(systemName: "trash")
                    }
                }
            }
        }label: {
            Image(systemName: "ellipsis").foregroundColor(color.buttonColor).padding().background(.clear)
        }
        
    }
}

struct entryLikeButton:View{
    var didLike:Bool
    var like:Int
    var action:() -> Void

    var body: some View{
            HStack {
                Image(systemName: didLike ? "hand.thumbsup.fill" : "hand.thumbsup").fontWeight(.light)
                Text("\(like)").font(.custom(CFont.ABO, size: Size.sizeLarge - 3))

            }.padding().foregroundColor(color.buttonColor).onTapGesture {
                action()
            }
        
    }
}
struct entryDate:View{
    var time:Date
    var body: some View{
        Text(timeAgo(from: time)).font(.custom("DINAlternate-Bold", size: Size.sizeSmall)).foregroundColor(color.dark.opacity(0.3)).fontWeight(.thin)
    }
    
    func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: date)

        let yearComponents = calendar.dateComponents([.year], from: startDate, to: today)
        let monthComponents = calendar.dateComponents([.month], from: startDate, to: today)
        let weekComponents = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
        let dayComponents = calendar.dateComponents([.day], from: startDate, to: today)

        if let yearAgo = yearComponents.year, yearAgo > 0 {
            return "\(yearAgo) year ago"
        } else if let monthAgo = monthComponents.month, monthAgo > 0 {
            return "\(monthAgo) month ago"
        } else if let weeksAgo = weekComponents.weekOfYear, weeksAgo > 0 {
            return "\(weeksAgo) week ago"
        } else if let daysAgo = dayComponents.day, daysAgo > 0 {
            return "\(daysAgo) day ago"
        } else {
            return "today"
        }
    }
}

struct afterText:View{
    var text:String
    var body: some View{
        Text(text).font(.custom("Avenir-Roman", size: Size.sizeLarge)).fontWeight(.bold).foregroundColor(color.dark)
    }
}
