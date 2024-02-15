import SwiftUI



struct profilePage: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var UTDPhoto:String
    @Binding var UTDNick:String
    @Binding var UTDEntry:Int
    @Binding var UTDEntryLike:Int
    @Binding var UTDSol:Int
    @Binding var UTDId:String
    @Binding var UTDBlocks:[String]
    
    @Binding var showInLogPage:Bool
    
    @State var showEditProfile:Bool = false
        
    @State var showSettings:Bool = false
    
    @State var mustDoEntry:Int = 1
    @State var levelEntry:Int = 1
    @State var totalEntryForMath:Int = 0
    
    @State var mustDoEntryLike:Int = 1
    @State var levelEntryLike:Int = 1
    @State var totalEntryLikeForMath:Int = 0
    var body: some View {
        
            GeometryReader { g in
                NavigationStack{
                    ZStack{
                        
                       List{
                            Section(header:Text("Your Profile")){
                                HStack{
                                    Spacer()
                                   
                                    if let urlAC = UserDefaults.standard.string(forKey: "photoPath"){
                                        entryProfilePhoto(url: urlAC, onlySize: 120)
                                       
                                    }else{
                                        
                                        Circle().fill(.white).frame(width: 120,height: 120).shadow(radius: 2).overlay(
                                            ProgressView().frame(width: 120,height: 120)
                                        )
                                    }
                                    
                                    
                                    
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
                                    
                                    Text("Achievements").font(.custom(CFont.AB, size: Size.sizeUltraLarge)).foregroundStyle(color.dark)
                                    VStack(alignment:.leading,spacing:60){
                                        numberRCords(mustDo: $mustDoEntry, totalForMath: $totalEntryForMath, level: $levelEntry, UTD: $UTDEntry, title: "Helpful", exp: "Share \(mustDoEntry) entry", endExp: "the entries you shared", image: "yardimsever", color1: color.mainCounter, color2:color.dark)
                                        
                                        numberRCords(mustDo: $mustDoEntryLike, totalForMath: $totalEntryLikeForMath, level: $levelEntryLike, UTD: $UTDEntryLike, title: "Like Magnet", exp: "get \(mustDoEntryLike) likes on your entries", endExp: "the number of likes you get on entries", image: "begenimagnet", color1: .red, color2: color.main)
                                        
                       
                                        numberRCords(mustDo: .constant(1), totalForMath: .constant(0), level: .constant(UTDSol > 0 ? 5 : 2), UTD: $UTDSol, title: "Renaissance", exp: "join a solidarity", endExp: "solidarities you participated in", image: "yenidendogus", color1: color.mainCounter, color2: .red)
                                    
                                    }
                                }
                                .padding(.vertical,20)

                            }.onChange(of: UTDEntry){ newValue in
                                mustDoEntry = missionMathEntry(entry: newValue).0
                                levelEntry = missionMathEntry(entry: newValue).1
                                totalEntryForMath = missionMathEntry(entry: newValue).2
                            }
                            .onChange(of: UTDEntryLike){ newValue in
                                mustDoEntryLike = missionMathEntryLike(entry: UTDEntryLike).0
                                levelEntryLike = missionMathEntryLike(entry: UTDEntryLike).1
                                totalEntryLikeForMath = missionMathEntryLike(entry: UTDEntryLike).2
                            }
                            
                        }.listStyle(.sidebar)
                            .padding(.bottom,60)
                            .refreshable {
                            refresh()
                            
                            }.task {
                                
                                mustDoEntry = missionMathEntry(entry: UTDEntry).0
                                levelEntry = missionMathEntry(entry: UTDEntry).1
                                totalEntryForMath = missionMathEntry(entry: UTDEntry).2
                                
                                mustDoEntryLike = missionMathEntryLike(entry: UTDEntryLike).0
                                levelEntryLike = missionMathEntryLike(entry: UTDEntryLike).1
                                totalEntryLikeForMath = missionMathEntryLike(entry: UTDEntryLike).2
                                
                            }
                 
                    }.toolbar{
                        ToolbarItem(placement: .topBarTrailing){
                            Menu{
                                Button(action: {
                                    showSettings.toggle()
                                }){
                                    HStack {
                                        Text("Settings")
                                        Image(systemName: "gearshape").font(.system(size: Size.sizeUltraLarge - 7)).foregroundColor(color.main)
                                    }
                                }
                                Button(action: {
                                    showEditProfile.toggle()
                                }){
                                    HStack {
                                        Text("Edit Profile")
                                        Image(systemName: "square.and.pencil").font(.system(size: Size.sizeUltraLarge - 7)).foregroundColor(color.main)
                                    }
                                }
                                
                                
                                
                            }label: {
                                Image(systemName: "gearshape.fill").font(.system(size: Size.sizeLarge)).foregroundColor(color.dark).padding(EdgeInsets(top: 5, leading: 5,bottom: 5, trailing: 0))
                            }
                        }
                        ToolbarItem(placement:.principal){
                            MGPTitlePiece(title: "Profile")
                        }
                    }
                }
            }.fullScreenCover(isPresented: $showSettings){
                settingsPage(showInLogPage: $showInLogPage, UID: $UTDId,UTDBlocks:$UTDBlocks).environment(\.colorScheme, .light)
        }.fullScreenCover(isPresented: $showEditProfile){
            editProfile(UID: $UTDId, back:$showEditProfile).environment(\.colorScheme, .light)
        }
    }
    
    func refresh(){
        Task{
            do{
                try await viewModel.loadCurrentUser()
                
                if let pUser = viewModel.Puser{
                    UTDPhoto = pUser.photoPath!
                    UTDNick = pUser.nickName!
                    UTDSol = pUser.profileSol!
                    UTDEntry = pUser.profileEntry!
                    UTDEntryLike = pUser.profileEntryLike!
                    
                    UserDefaults.standard.setValue(pUser.photoPath, forKey: "photoPath")
                    UserDefaults.standard.setValue(pUser.nickName, forKey: "nickName")
                }
            }catch{
                
            }
        }
    }
}


struct profilePage_Previews: PreviewProvider {
    static var previews: some View {
        profilePage(UTDPhoto: .constant("1234"), UTDNick: .constant("12345"), UTDEntry: .constant(0), UTDEntryLike: .constant(0), UTDSol: .constant(0), UTDId: .constant("12345"), UTDBlocks: .constant([]), showInLogPage: .constant(false))
    }
}

struct numberRCords:View{
    @Binding var mustDo:Int
    @Binding var totalForMath:Int
    @Binding var level:Int
    @Binding var UTD:Int
    
    var title:String
    var exp:String
    var endExp:String
    var image:String
    var color1:Color
    var color2:Color

    
    var body: some View{
        
        HStack(spacing: 15){
            profileSuccessImage(image: image, level: level)
            
            VStack(alignment:.leading,spacing:12){
                Text(title).font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.bold)
                if(level < 5){
                    Text(exp).font(.custom(CFont.ABO, size: Size.sizeMedium)).fontWeight(.semibold)
                    
                    HStack{
                        
                        progressBarView(width: 140,percent: CGFloat(((UTD - totalForMath) * (100 / mustDo))),color1: color1,color2:color2)
                        Text("\(UTD - totalForMath)/\(mustDo)").font(.custom(CFont.AB, size: Size.sizeLarge)).opacity(0.3)
                        
                    }
                }else{
                    Text(endExp).font(.custom(CFont.ABO, size: Size.sizeMedium)).fontWeight(.semibold)
                    
                    HStack{
                        progressBarView(width: 140,percent: CGFloat(100),color1: color1,color2:color2)
                        Text("\(UTD)").font(.custom(CFont.AB, size: Size.sizeLarge)).opacity(0.3)
                    }
                    
                }
            }
            .font(.custom(CFont.ABO, size: Size.sizeMedium))
            
        }.foregroundColor(color.dark)
    }
}
func missionMathEntry(entry:Int) -> (Int,Int,Int){
    var mustDo:Int = 0
    var level:Int = 0
    var totalEntry:Int = 0
    
    switch entry{
    case ...1:
        mustDo = 2
        level = 1
        totalEntry = 0
    case 1...4:
        mustDo = 3
        level = 2
        totalEntry = 2
    case 5...12:
        mustDo = 8
        level = 3
        totalEntry = 5
    case 13...21:
        mustDo = 9
        level = 4
        totalEntry = 13
    default:
        level = 5
    }
    return (mustDo,level,totalEntry)
}
func missionMathEntryLike(entry:Int) -> (Int,Int,Int){
    var mustDo:Int = 0
    var level:Int = 0
    var totalEntry:Int = 0
    
    switch entry{
    case ...1:
        mustDo = 2
        level = 1
        totalEntry = 0
    case 1...6:
        mustDo = 5
        level = 2
        totalEntry = 2
    case 7...14:
        mustDo = 8
        level = 3
        totalEntry = 7
    case 15...30:
        mustDo = 16
        level = 4
        totalEntry = 15
    default:
        level = 5
    }
    return (mustDo,level,totalEntry)
}

struct profileSuccessImage:View {
    var image:String
    var level:Int
    var body: some View {
        
            
            Image(image).resizable().scaledToFill().frame(width:95,height: 95).cornerRadius(12).overlay{
                VStack{
                    Spacer()
                    HStack(spacing:2){
                        
                        ForEach(1...level,id: \.self){ x in
                            if(x != 1){
                                Image(systemName: "star.fill").font(.system(size: Size.sizeMedium - 3)).foregroundStyle(color.mainCounter).shadow(radius: 1)
                            }
                        }
                    }.frame(maxWidth: .infinity).padding(.vertical,3).background(.ultraThinMaterial.opacity(level > 1 ? 0.95 : 0)).cornerRadius(12, corners: [.bottomLeft,.bottomRight])
                }
            }
    }
}
