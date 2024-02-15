import SwiftUI
struct ADMINADDVIEW: View {
    @StateObject private var SolidManager = solidManager()
    @State var title:String = ""
    @State var exp:String = ""
    var body: some View {
        VStack{
            List{
                Section{
                    TextField("title", text: $title)
                }
                Section{
                    TextField("exp", text: $exp)
                }
                Section{
                    Button(action: {
                        Task{
                            do{
                                try await SolidManager.addSolid(title: title, exp: exp)
                            }catch{
                                
                            }
                        }
                    }){
                        Text("ADD")
                    }
                }
            }
        }
    }
}
struct mainGPage: View {
    @StateObject private var SolidManager = solidManager()
    @StateObject private var viewModel = ProfileViewModel()
    @State var firstLogIn:Bool = false
    @Binding var showInLogPage:Bool
    @State var stateControl:Int = 0
    @State var UTDPhoto:String = ""
    @State var UTDNick:String = ""
    @State var UTDEntry:Int = 0
    @State var UTDEntryLike:Int = 0
    @State var UTDSol:Int = 0
    @State var UTDId:String = ""
    @State var UTDBlocks:[String] = []
    @State var UTDBan:Bool = false
    @Binding var ST:Tab
    @State var activeST:Tab = .house
    @State var poJoin:Bool = false
    @State var po1:Bool = false
    @State var jSucc:Bool = false
    @State var jLeav:Bool = false
    var body: some View {
        GeometryReader{ g in
      
            ZStack{
                color.white.ignoresSafeArea()
                house(showInLogPage: $showInLogPage, id: $UTDId,UTDName: $UTDNick, UTDPhoto:$UTDPhoto, UTDId: $UTDId, UTDBlock: $UTDBlocks).opacity(activeST.rawValue == "house" ? 1 : 0)
                if(!UTDId.isEmpty){
                    discover(showInLogPage: $showInLogPage,UTDId: $UTDId, poJoin: $poJoin).opacity(activeST.rawValue == "binoculars" ? 1 : 0)
                }else{
                    VStack{
                        ProgressView()
                    }.background(color.white).opacity(activeST.rawValue == "binoculars" ? 1 : 0)
                }
                
                profile(UTDPhoto: $UTDPhoto, UTDNick: $UTDNick, UTDEntry: $UTDEntry, UTDEntryLike: $UTDEntryLike, UTDSol: $UTDSol, UTDId: $UTDId, UTDBlocks: $UTDBlocks, showInLogPage: $showInLogPage).opacity(activeST.rawValue == "person" ? 1 : 0)
           
            }.fullScreenCover(isPresented: $firstLogIn, content: {
                firstLog(viewModel: .constant(viewModel), userName: .constant("")).environment(\.colorScheme, .light)
            }).fullScreenCover(isPresented: $UTDBan, content: {
                bannedPage(inLogPageShow: $showInLogPage,UTDId:$UTDId)
            }).task {
                do{
                    try await viewModel.loadCurrentUser()
                    
                    if let pUser = viewModel.Puser{
                        UTDPhoto = pUser.photoPath!
                        UTDNick = pUser.nickName!
                        UTDSol = pUser.profileSol!
                        UTDEntry = pUser.profileEntry!
                        UTDEntryLike = pUser.profileEntryLike!
                        UTDBlocks = pUser.blocks!
                        UTDBan = pUser.ban!
                        
                        UserDefaults.standard.setValue(pUser.photoPath, forKey: "photoPath")
                        UserDefaults.standard.setValue(pUser.nickName, forKey: "nickName")
                    }
                    
                    if let user = viewModel.user{
                        SolidManager.fPhotoUrlLink(UID: user.userId)
                        UTDId = user.userId
                        
                        UserDefaults.standard.set(user.userId, forKey: "userUIDD")
                        
                        UserManager.shared.userDataControl(uuid: user.userId) { exists in
                            if exists {
                                print("ProfileData collection exists.")
                            } else {
                                print("kayıt bulunamadı \(user.userId)")
                                firstLogIn = true
                            }
                        }
                       

                    }
                }catch{
                    print("ERROR MAINPAGE")
                }
            }.onAppear{
                activeST = ST
            }
            .onChange(of: poJoin){
                if poJoin{
                    po1 = true
                }
            }
            customTabBar(selectedTab: $activeST,po1: $po1)
        }
    }
}


struct mainGPage_Previews: PreviewProvider {
    static var previews: some View {
        mainGPage(showInLogPage: .constant(false), ST: .constant(.house))
    }
}





struct house:View{
    
    @ObservedObject var SavingsDateManager = savingsDateManager()
    @Binding var showInLogPage:Bool
    @Binding var id:String
    @Binding var UTDName:String
    @Binding var UTDPhoto:String
    @Binding var UTDId:String
    @Binding var UTDBlock:[String]
    @StateObject var SolidManager = solidManager()
    
    func getDataSelf() async throws{
        if(!id.isEmpty){
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            do{
                try await SolidManager.readOwnSolid(userId: id)
            }catch{
                
            }
        }
    }
    
    var body: some View{
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    VStack{
                        
                        ScrollView{
                            MGPsubTitlePiece(title: "Solidarities")
                                
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 60) {
                                if(SolidManager.solidList.isEmpty){
                                    VStack(spacing:10){
                                        HStack{
                                            Text("this place looks empty").font(.custom(CFont.ABO, size: Size.sizeLarge))
                                            Image(systemName:"eyes").font(.system(size: 40)).fontWeight(.ultraLight).opacity(1)
                                        }
                                        Text("There is no solidarity you participate in").font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold).opacity(0.3)
                                        HStack{
                                            Text("Click the")
                                            Image(systemName: "binoculars")
                                            Text("below to join")
                                        }.font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold).opacity(0.3)
                                        
                                    }.foregroundStyle(color.dark)
                                }
                                ForEach(SolidManager.solidList) { SL in
                                    solidView(UTDName: $UTDName, UTDPhoto:$UTDPhoto,UTDId: $UTDId, showInLogPage: $showInLogPage,UTDBlock:$UTDBlock,idOriginal: SL.idOriginal, id:SL.id,whichDays: SL.whichDays, savingsNumber:SL.savingsNumber,savingsNumberTitles: SL.savingsNumberStrings,savingsTitles: SL.savingsStrings, date: SL.date, title: SL.solidName,moods:SL.moods,moodsDate:SL.moodsDate, day: SavingsDateManager.dayMath(date: SL.date) + 1,why:SL.why, action: {})
                                }
                            }
                            .padding(.top,35)
                            .padding(.bottom, 60)
                        }         

                    }
                }
                .toolbar{
                    ToolbarItem(placement: .principal){
                        MGPTitlePiece(title: "Home")
                    }
                }
                .onChange(of: id){ newValue in
                    if(!id.isEmpty){
                        Task{
                            do{
                                try await SolidManager.readOwnSolid(userId: id)
                            }catch{
                                
                            }
                        }
                    }
                }
            }.refreshable {
                do{
                    try await getDataSelf()
                }catch{
                    
                }
            }
        }
    }
}

struct MGPTitlePiece: View {
    var title:String
    var body: some View {
        Text(title).foregroundStyle(color.dark).font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold)
    }
}
struct MGPsubTitlePiece: View {
    var title:String
    var body: some View {
        HStack{
            Text(title).font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundColor(color.dark).fontWeight(.semibold)
            Spacer()
        }.padding(.leading,20)
    }
}
struct discover:View{
    @Binding var showInLogPage:Bool
    @StateObject var SolidManageR = solidManager()
    @State private var isExpanded: Bool = false
    @State private var searchText: String = ""
    @State var sheetHeight:CGFloat = .zero
    @State var sCreate:Bool = false
  //  @State var showJoin:Bool = false

    @State var SH:CGFloat = .zero
    @Binding var UTDId:String
    @Binding var poJoin:Bool
    var body: some View{
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    ScrollView{
                        MGPsubTitlePiece(title: "Recommended Solidarities")
                            
                        Divider()

                        VStack(alignment: .leading, spacing: 60) {
                            
                            ForEach(SolidManageR.solid) { x in
                                
                                discoverView(UID: $UTDId, poJoin: $poJoin, id:x.id,idOriginal: x.id, title: x.title, person: x.person, urlLink: x.url, emoji: x.emoji, exp:x.exp,action: {
                                    
                                   // showJoin.toggle()
                                   
                                })
                            }
                        }
                        .padding(.top,35)
                        .padding(.bottom, 60)
                        .task {
                            SolidManageR.fetchNonMatchingSolids(userId: ID.userUID, prefix: searchText)
                        }
                        .refreshable {}
                        
                    }
                    .toolbar{
                        
                        ToolbarItem(placement: .topBarTrailing){
                            NavigationLink(destination: searchPage(UTDId: $UTDId, pojoin: $poJoin)){
                                Image(systemName: "magnifyingglass").foregroundStyle(color.dark)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing){
                            NavigationLink(destination: globalPage()){
                                Image(systemName: "note.text.badge.plus").foregroundStyle(color.dark)
                            }
                        }

                        ToolbarItem(placement: .principal) {
                            MGPTitlePiece(title: "Discover")
                        }
                        
                    }
                }
            }
            .sheet(isPresented: $sCreate){
                globalPage().presentationCornerRadius(20).presentationDetents(sheetHeight == .zero ? [.medium] :[.height(sheetHeight)]).environment(\.colorScheme, .light)
            }
        }
    }
}
struct joinPhoto:View{

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
struct joinViewPieceLater:View {
    var infoT:String
    var infoC:String
    var infoW:String
    var image:String
    var imageColor:Color
    var body:some View{
        VStack(spacing:20){
            Image(systemName: image).foregroundStyle(imageColor).font(.system(size: 35))
            Text(infoT).font(.custom(CFont.AM, size: Size.sizeLarge))
         
            VStack(spacing:5){
                Text(infoC).font(.custom(CFont.AM, size: Size.sizeLarge)).opacity(0.35)
                HStack(alignment:.center,spacing:0){
                    Text(infoW)
                    Image(systemName: "house")
                    Text("]")
                }.font(.custom(CFont.AM, size: Size.sizeMedium))
            }
        }
        .foregroundStyle(color.dark)
    }
}
struct joinView:View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var SolidManageR = solidManager()
    @Binding var success:Bool
    @Binding var SO:Solid
    @Binding var didSave:Bool
    @Binding var documentID:String
    @Binding var loading:Bool
    
    @State var result:Int = 0
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    var Id:String
    var UTDId:String
    @Binding var poJoin:Bool
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing:40){
                    VStack(spacing:10){
                        joinPhoto(url: SO.url, onlySize: 80)
                        
                        Text("\(SO.title) Addiction").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.dark)
                        Text("\(SO.person) member").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.main).fontWeight(.heavy)
                    }
                    if(result == 0){
                        VStack(alignment:.leading,spacing:10){
                            
                            Text("\(SO.exp)").font(.custom(CFont.AM, size: Size.sizeMedium)).foregroundStyle(color.dark)
                        }
                    }else if(result == 1){
                        joinViewPieceLater(infoT: "You Joined Solidarity", infoC: "[ Click to finish ]", infoW: "[ Added to  ",image:"checkmark.seal.fill",imageColor: .green)
                     
                    }else if(result == 2){
                        joinViewPieceLater(infoT: "You Left Solidarity", infoC: "[ Click to finish ]", infoW: "[ Removed from ",image:"xmark.seal.fill",imageColor: .red)
                    }
                    
                    Spacer()
                }.padding(.top,15)
                
            }.padding(20)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if(result > 0){
                        self.presentationMode.wrappedValue.dismiss()
                       
                    }
                }
                .toolbar{
                    if(result == 0){
                        ToolbarItem(placement: .bottomBar){
                            Button(action: {
                                loading = true
                                Task {
                                    do {
                                        if(didSave){
                                            try await SolidManageR.deleteSolid(UID: UTDId, DOCID: documentID, realDocID:Id )
                                            withAnimation{
                                                result = 2
                                            }
                                            SO.person -= SO.person

                                            loading = false
                                            
                                        }else{
                                            try await SolidManageR.saveSolid(solid: SolidOwn(id: "", solidName: SO.title, date: Date(), savingsNumber: [], savingsNumberStrings: [], savingsStrings: [], why: "", whichDays: [], idOriginal: SO.id, person: SO.person,moods:[],moodsDate: yesterday), userId: UTDId, docId: SO.id)
                                            withAnimation{
                                                result = 1
                                            }
                                            SO.person += SO.person
                                         poJoin = true
                                            loading = false
                                            
                                            
                                        }
                                        
                                    } catch {
                                        print("error: \(error)")
                                    }
                                }
                            }){
                                HStack{
                                    if(loading){
                                        ProgressView()
                                    }else{
                                        Text(didSave ? "Leave" : "Join")
                                    }
                                    
                                }.frame(width: 140,height: 50).font(.custom(CFont.AH, size: Size.sizeLarge)).foregroundStyle(color.white).background(didSave ? .red : color.main).cornerRadius(20)
                            }.disabled(loading)
                        }
                    }
                }
        }
            
    }
}


/// view içindeki kesit viewlar

struct solidView:View{
    @StateObject var SolidManager = solidManager()
    @StateObject var entry = entryManager()
    @Binding var UTDName:String
    @Binding var UTDPhoto:String
    @Binding var UTDId:String
    @Binding var showInLogPage:Bool
    @Binding var UTDBlock:[String]
    @State var stage:Int = 0
    @State var urlLink:String = ""
    var idOriginal:String
    var id:String
    var whichDays:[Int]
    var savingsNumber:[Int]
    var savingsNumberTitles:[String]
    var savingsTitles:[String]
    var date:Date
    var title:String
    var moods:[String]
    var moodsDate:Date
    @State var showDetail:Bool = false
    @State var person:Int = 99
    var day:Int
    var why:String
    var action:() -> Void
    var body: some View{
        HStack{
            discoverViewImage(urlLink: urlLink)
            
            solidViewPieceTexts(title: title, person: person, emoji: [], day: day, isDiscover: false,dateLast: .constant(moodsDate))
                .frame(height: 40)
                .padding()
                .fullScreenCover(isPresented: $showDetail){
                
                
                    detailGPage(UTDName: $UTDName, UTDPhoto:$UTDPhoto,UTDId: $UTDId,UTDSolidImage: $urlLink, id:.constant(id),day: .constant(day), title:.constant(title),why:.constant(why),stage: $stage, whichDays: .constant(whichDays), startDate: .constant(date), saveStrings: .constant(savingsTitles), saveInt: .constant(savingsNumber), saveIntStrings: .constant(savingsNumberTitles),UTDBlock:$UTDBlock,moods: .constant(moods),moodsDate: .constant(moodsDate))
 
            }
            Spacer()
        }.onAppear{
            SolidManager.getUrlLink(orID: idOriginal, completion: { value in
                if let value = value{
                    urlLink = value
                }
                
            })
            SolidManager.getMember(title: idOriginal) { member, error in
                if let error = error {
                    // Hata işleme
                    self.person = 98
                } else if let member = member {
                    // 'person' değeri ile işlem yapma
                    self.person = member
                } else {
                    // 'person' değeri yok veya beklenen formatta değil
                    self.person = 101
                }
            }
            
            stage = entry.entryStageMath(actualDay: day).0
            
        }.padding(.leading,20).onTapGesture {
            showDetail.toggle()
            action()
        }
    }
}
struct discoverViewImage:View {
    var urlLink:String
    var body: some View {
        AsyncImage(url: URL(string: urlLink)){ image in
            
            image.resizable().scaledToFill().frame(width:95,height: 95).cornerRadius(20)
            
        }placeholder: {
        
            RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.2)).frame(width: 95,height: 95).overlay{
                ProgressView()
            }
        }
    }
}
struct discoverViewPieceTexts:View {
    var title:String
    var person:Int
    var emoji:[String]
    var day:Int
    var isDiscover:Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            
            VStack(alignment: .leading, spacing: 2){
                HStack{
                    Text(title)
                    Text("Addiction").opacity(0.3)
                }
                .font(.custom(CFont.ABO, size: Size.sizeLarge))
                .foregroundStyle(color.dark)
                
            }
            .fontWeight(.semibold)
            HStack(spacing: 15){
                RoundedRectangle(cornerRadius: 7).fill(.white).frame(width: 55,height: 30).shadow(radius: 1).overlay{
                    HStack(spacing:2){
                        Image(systemName: "person.fill")
                        
                        Text("\(person)")
                           
                        
                    }.font(.custom(CFont.ABO, size: Size.sizeMedium))
                        .foregroundStyle(color.main)
                }
            
            if(isDiscover){
                HStack{
                    ForEach(0...emoji.count - 1,id:\.self){ x in
                        Circle()
                            .fill(color.white)
                            .shadow(radius: 1)
                            .frame(width: 26,height: 26)
                            .overlay{
                                
                                Text(emoji[x]).font(.custom("Avenir-Roman", size: Size.sizeSmall + 1))
                                
                            }
                            .transformEffect(.init(translationX: x > 0 ? CGFloat((-16 * x)) : 0, y: 0))
                    }
                }.frame(height: 30)
            }else{
                RoundedRectangle(cornerRadius: 40).fill(.white).frame(width: 25,height:25).shadow(radius: 1).overlay{
                    HStack(spacing:3){
                 
                        Text("\(day)")
                            .fontWeight(.regular)
                    }
                    .font(.custom(CFont.ABO, size: Size.sizeMedium))
                    .foregroundStyle(color.dark)
                }
                
            }
             
            }
        }
    }
}
struct solidViewPieceTexts:View {
    var title:String
    var person:Int
    var emoji:[String]
    var day:Int
    var isDiscover:Bool
    @Binding var dateLast:Date
    let today = Date()

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            
            VStack(alignment: .leading, spacing: 2){
                HStack{
                    Text(title)
                    Text("Addiction").opacity(0.3)
                }
                .font(.custom(CFont.ABO, size: Size.sizeLarge))
                .foregroundStyle(color.dark)
                
            }
            .fontWeight(.semibold)
            HStack(spacing: 15){
                RoundedRectangle(cornerRadius: 7).fill(.white).frame(width: 55,height: 30).shadow(radius: 1).overlay{
                    HStack(spacing:2){
                        Image(systemName: "person.fill")
                        
                        Text("\(person)")
                           
                        
                    }.font(.custom(CFont.ABO, size: Size.sizeMedium))
                        .foregroundStyle(color.main)
                }
            
            if(isDiscover){
                HStack{
                    ForEach(0...emoji.count - 1,id:\.self){ x in
                        Circle()
                            .fill(color.white)
                            .shadow(radius: 1)
                            .frame(width: 26,height: 26)
                            .overlay{
                                
                                Text(emoji[x]).font(.custom("Avenir-Roman", size: Size.sizeSmall + 1))
                                
                            }
                            .transformEffect(.init(translationX: x > 0 ? CGFloat((-16 * x)) : 0, y: 0))
                    }
                }.frame(height: 30)
            }else{
                RoundedRectangle(cornerRadius: 40).fill(.white).frame(width: 25,height:25).shadow(radius: 1).overlay{
                    HStack(spacing:3){
                        //Image(systemName: "timelapse").font(.system(size: Size.sizeMedium))
                        Text("\(day)")
                            .fontWeight(.regular)
                    }
                    .font(.custom(CFont.ABO, size: Size.sizeMedium))
                    .foregroundStyle(color.dark)
                    
                }
                if !Calendar.current.isDate(today, inSameDayAs: dateLast) {
                    RoundedRectangle(cornerRadius: 40).fill(.white).frame(width: 25,height:25).shadow(radius: 1).overlay{
                        HStack(spacing:3){
                            Image(systemName:"bell.badge")                        .foregroundStyle(.red)
                                

                        }
                        
                    }
                }else{
                    RoundedRectangle(cornerRadius: 40).fill(.white).frame(width: 25,height:25).shadow(radius: 1).overlay{
                        HStack(spacing:3){
                            Image(systemName:"bell.badge").foregroundStyle(color.dark)
                                .opacity(0.3)
                        }
                        
                    }
                }
                
            }
             
            }
        }
    }
}
struct discoverView:View{ // keşfet bölümündeki solid kutucukları...
    
    @StateObject var SolidManager = solidManager()
    @State var sJoin = false
    @State var documentID:String = ""
    @State var didSave:Bool = false
    @State var loadingFromJoin:Bool = false
    
    
    @Binding var UID:String
    @Binding var poJoin:Bool
    @State var poJoinC:Bool = false

    var id:String
    var idOriginal:String
    var title:String
    var person:Int
    var urlLink:String
    var emoji:[String]
    var exp:String
    var action:() -> Void
    
    var body: some View{
        HStack{
            
            discoverViewImage(urlLink: urlLink) ///solidarity image
            
            
            discoverViewPieceTexts(title: title, person: person, emoji: emoji, day:0, isDiscover: true)
            .frame(height: 40)
            .padding()
            
            
            
            
            
            
            Spacer()
            
        }.padding(.leading, 20)
            .onTapGesture {
                sJoin.toggle()
                action()
            }.onAppear{
            SolidManager.controlSolidHas(UID: UID, title: title, completion: { value in
                if let id = value{

                    didSave = true
                    documentID = id
                    
                }else{

                    didSave = false
                }
                
            })
            }.onChange(of: sJoin){
                if (poJoinC && !sJoin){
                    if !UserDefaults.standard.bool(forKey: "CTBHelper"){
                        poJoin = true
                    }
                }
            }
        .sheet(isPresented: $sJoin){
            joinView(success: $sJoin, SO: .constant(Solid(id: id, title: title, person: person, url: urlLink, language: "", emoji: emoji, exp: exp)),didSave:$didSave, documentID: $documentID,loading: $loadingFromJoin, Id:id,UTDId:UID, poJoin: $poJoinC).environment(\.colorScheme, .light).presentationCornerRadius(20).presentationDetents([.height(400)]).interactiveDismissDisabled(loadingFromJoin)
        }
        
        
    }
}

struct profile:View{
    
    @Binding var UTDPhoto:String
    @Binding var UTDNick:String
    @Binding var UTDEntry:Int
    @Binding var UTDEntryLike:Int
    @Binding var UTDSol:Int
    @Binding var UTDId:String
    @Binding var UTDBlocks:[String]

    @Binding var showInLogPage:Bool
    var body: some View{
        profilePage(UTDPhoto: $UTDPhoto, UTDNick: $UTDNick, UTDEntry: $UTDEntry, UTDEntryLike: $UTDEntryLike, UTDSol: $UTDSol, UTDId: $UTDId,UTDBlocks:$UTDBlocks, showInLogPage: $showInLogPage)
        
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
