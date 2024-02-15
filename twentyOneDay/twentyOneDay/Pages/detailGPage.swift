import SwiftUI

struct detailGPage: View {
    @StateObject var entry = entryManager()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var UTDName:String
    @Binding var UTDPhoto:String
    @Binding var UTDId:String
    @Binding var UTDSolidImage:String
    @Binding var id:String
    @Binding var day:Int
    @Binding var title:String
    @Binding var why:String
    @Binding var stage:Int

    @Binding var whichDays:[Int]
    @Binding var startDate:Date
    @Binding var saveStrings:[String]
    @Binding var saveInt:[Int]
    @Binding var saveIntStrings:[String]
    @Binding var UTDBlock:[String]
    
    @Binding var moods:[String]
    @Binding var moodsDate:Date
    @State var moodsControl:Bool = false
    let today = Date()
    @State var stageD:adictionStage = .awareness

    
    @State private var saveStringsUS:[String] = []
    @State private var saveIntUS:[Int] = []
    @State private var saveIntStringsUS:[String] = []
    @State private var whichDaysUS:[Int] = []
    @State private var whyUS:String = ""
    @State private var dateUS:Date = .now
    @State var showInfoPage:Bool = false
    @State var tabViewSelection:Int = 0
    @State var againOpen:Bool = false
    
    @State var po1:Bool = false
    @State var po2:Bool = false
    
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    
                    ScrollView{
                        VStack(spacing:30){
                            
                            TabView(selection: $tabViewSelection){
                                
                                mainRec(date: $startDate, showInfoPage: $showInfoPage, title: $title, day: $day, stage: $stage, po1:$po1,po2:$po2, geoHeight: geo.size.height).tag(0)
                                
                                saveRect(whichDays: $whichDaysUS, Date: $startDate, saveStrings: $saveStringsUS, saveInt: $saveIntUS, saveIntStrings: $saveIntStringsUS, geoHeight: geo.size.height).tag(1)
                                
                                lastRect(UID:$UTDId,id: $id, savingsStrings: $saveStringsUS, savingsNumber: $saveIntUS, savingsNumberStrings: $saveIntStringsUS, title: $title, date: $dateUS, whichDays: $whichDaysUS, why: $whyUS, geoHeight: geo.size.height).tag(2)
                                
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)).frame(height: geo.size.height / 1.8)
                            
                            
                         
                            down(stage: $stage, sol: $title, day: $day, UTDId: $UTDId,UTDBlock:$UTDBlock ,CG: geo.safeAreaInsets.top, geoHeight: geo.size.height, geoWidth: geo.size.width)
                        }
                    }
                    VStack{
                        
                     Spacer()
                        HStack{
                            Spacer()
                            NavigationLink(destination: sendEntry(UTDPhoto:$UTDPhoto,UTDId: $UTDId, day: $day, sol: $title, stage: $stage)){
                                Circle().fill(color.main.gradient).shadow(radius: 4).frame(width: 50,height: 50).overlay{
                                    Image(systemName: "plus").foregroundStyle(.white).font(.system(size: Size.sizeLarge + 4)).fontWeight(.bold)
                                }
                            }
                           
                        }
                    }.padding()
                }
                
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        Button(action: {
                            if(saveStrings != saveStringsUS || whyUS != why){
                                againOpen = true
                            }else{
                                presentationMode.wrappedValue.dismiss()
                            }
                        }){
                            Image(systemName: "chevron.down").foregroundStyle(color.dark).fontWeight(.bold)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing){
                        
                        NavigationLink(destination: messages(chatTitle: .constant(title), dayString: .constant(day),solidImage: .constant(UTDSolidImage),UTDId: $UTDId,UTDName: $UTDName,UTDBlocks: $UTDBlock)){
                            VStack{
                                Image(systemName: "paperplane.fill").foregroundStyle(color.dark).fontWeight(.regular)
                            }.overlay{
                                
                            }
                            
                        }
                          

                      
                    }
                   
                }
            }.onChange(of: po1){
                if !po1{
                    po2 = true
                }
            }.onChange(of: po2){
                if !po2{
                    UserDefaults.standard.set(true, forKey: "helperDGP")
                }
            }.onAppear{
                if(!UserDefaults.standard.bool(forKey: "helperDGP")){
                    po1 = true
                }
                stageD = entry.entryStageMath(actualDay: day).2

                UIScrollView.appearance().isScrollEnabled = true
                saveStringsUS = saveStrings
                saveIntUS = saveInt
                saveIntStringsUS = saveIntStrings
                whichDaysUS = whichDays
                dateUS = startDate
                whyUS = why
                stage = entry.entryStageMath(actualDay: day).0
                
                if !Calendar.current.isDate(today, inSameDayAs: moodsDate) {
                    moodsControl = true
                }
            }
            .fullScreenCover(isPresented: $moodsControl){
                dailyPage(day: $day,userEmojies: $moods, urlPhoto: $UTDSolidImage, sol: $title, UID: $UTDId, ID: $id,stageD:$stageD,stage:$stage,mControl:$moodsControl)
            }
            .fullScreenCover(isPresented: $againOpen){
                rootView(ST: .constant(.house)).environment(\.colorScheme, .light)
            }
        }
    }
}

#Preview {
    detailGPage(UTDName:.constant("1234"),UTDPhoto: .constant("a234"),UTDId: .constant("") ,UTDSolidImage: .constant(""), id: .constant(""), day: .constant(1), title:.constant("Instagram"),why: .constant("burda nedeni yazıyor"),stage: .constant(1),whichDays: .constant([1,3]), startDate: .constant(Date()), saveStrings: .constant(["cons 1", "cons 2"]), saveInt: .constant([20,60]), saveIntStrings: .constant(["C","B"]),UTDBlock: .constant([]),moods:.constant([]),moodsDate:.constant(Date()))
}

struct down: View {
    @State private var solEntries: [SolEntry] = []

    
    @StateObject private var viewModel = SolEntryViewModel()

    @State private var headerOffset: CGFloat = 0
    
    @Binding var stage:Int
    @Binding var sol:String
    @Binding var day:Int
    @Binding var UTDId:String
    @Binding var UTDBlock:[String]
    var CG:CGFloat
    
    
    @State var insideStage:Int = 0
    @State var isItAll:Bool = true
    @State var onlyEmoji:String = "-"
    
    @State var lastCount:Int = 0
    @State var moreBtnShow:Bool = false
    
    var geoHeight:CGFloat
    var geoWidth:CGFloat
    var body: some View {
        LazyVStack(alignment:.leading,spacing: 15,pinnedViews: [.sectionHeaders]){
            
            Section(header: entryTopArea(day:$day,solidarityName:$sol,stageInside: $insideStage, isItAll: $isItAll, onlyEmoji: $onlyEmoji)
                .padding(.bottom,0)
                
            ){
                HStack{
                    
                    Spacer()
                    
                        VStack(spacing:10){
                            
                            Text("stage \(insideStage)").font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold).foregroundStyle(color.dark)
                            color.dark.frame(width: 115,height: 1)
                            Text("what they felt and experienced on which day").font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold).foregroundStyle(color.dark)
                                
                            Image(systemName: "arrow.down.circle.dotted").font(.system(size: Size.sizeLarge + 5))
                            
                            
                        }.opacity(0.27)
                    
                    
                        
                    Spacer()
                }
                .padding(.vertical,17).padding(.bottom,15)
                if(viewModel.solEntries.isEmpty){
                    
                    VStack(alignment:.center,spacing:25){
                        
                        Menu{
                            Text("It's so quiet here,\nI hear my own echo.")
                        }label: {
                            Image(systemName: "tortoise.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(color.main)
                        }
                       
                            
                       
                        
                        Text("there are no entries here").fontWeight(.heavy).opacity(0.3)
                        
                        VStack(spacing:10){
                            Text("you can keep the first entry")
                            Image(systemName: "arrow.down.right.circle")
                                .font(.system(size: 30))
                                .fontWeight(.light)
                                
                        }
                    }
                    .foregroundStyle(color.dark)
                    .font(.custom(CFont.ABO, size: Size.sizeLarge))
                    .padding(.horizontal,20)
                    .padding(.top,25)
                    .frame(maxWidth: .infinity)
                }
                ForEach(viewModel.solEntries) { entry in
                    if !UTDBlock.contains(entry.userid) {
                        entryView(entry: SolEntry(id: entry.id, text: entry.text, day: entry.day, sol: entry.sol, stage: entry.stage, time: entry.time, emoji: entry.emoji, userid: entry.userid, likes: entry.likes), userId: .constant(entry.userid), UTDId: $UTDId,UTDBlock: $UTDBlock)
                    }
                }
                    
                Button(action: {
                    viewModel.fetchMoreSolEntries(all: isItAll, stage: insideStage, sol: sol, emoji: onlyEmoji)
   
                    if(viewModel.solEntries.count == lastCount){
                        moreBtnShow = true
                        
                    }else{
                        lastCount = viewModel.solEntries.count
                        
                    }
                    
                }){
                    HStack{
                        Text("Show more").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.main)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundStyle(color.dark.opacity(0.5))
                    }
                    .padding()
                    .opacity(viewModel.solEntries.isEmpty || !viewModel.solEntries.count.isMultiple(of: 5) || moreBtnShow ? 0 : 1 )
                }
                
                
            }
        }.padding(.bottom,90)
            .task{
                if(insideStage == 0){insideStage = stage}
                
                viewModel.fetchInitialSolEntries(all: isItAll, stage: insideStage, sol: sol, emoji: onlyEmoji)
                
                lastCount = viewModel.solEntries.count
                
                
                
            }
        
        
    }
}
        
    
struct entryTopArea: View {
    @ObservedObject private var entryViewModel = SolEntryViewModel()

    
    @Binding var day:Int
    @Binding var solidarityName:String
    @Binding var stageInside:Int
    @Binding var isItAll:Bool
    @Binding var onlyEmoji:String
    
    @State var sheetHeight:CGFloat = .zero
    @State var showFilter:Bool = false
    var body: some View {    
        
        Rectangle().fill(Color.white).frame(maxWidth: .infinity,minHeight: 70).shadow(color:color.dark.opacity(0.2),radius: 6,y: -4).overlay{
                    
                  
                    
                    HStack(alignment:.center,spacing:30) {
                        Text("Entries").font(.custom(CFont.ABO, size: Size.sizeLarge))
                            .fontWeight(.semibold)
                            .foregroundStyle(color.dark)

                        Spacer()
                        
                        
                        NavigationLink(destination: filterPage(stageNumber: $stageInside, all: $isItAll, emoji: $onlyEmoji)){
                            Image(systemName: "line.3.horizontal.decrease").foregroundColor(color.dark).fontWeight(.semibold).font(.system(size: Size.sizeUltraLarge - 15))
                        }
                        
                    }.frame(maxWidth: .infinity).padding(20).background(Color.white)

                
        }.onChange(of:isItAll){
            entryViewModel.fetchInitialSolEntries(all: isItAll, stage: stageInside, sol: solidarityName, emoji: onlyEmoji)
        }.onChange(of:stageInside){
            entryViewModel.fetchInitialSolEntries(all: isItAll, stage: stageInside, sol: solidarityName, emoji: onlyEmoji)
        }.onChange(of:onlyEmoji){
            entryViewModel.fetchInitialSolEntries(all: isItAll, stage: stageInside, sol: solidarityName, emoji: onlyEmoji)
        }
               
    }
}

struct customButtonLR: View {
    
    var image:String
    var title:String
    
    var body: some View {
        
        VStack(spacing: 10){
            Image(systemName: image).font(.system(size: Size.sizeLarge + 5))
            Text(title).font(.custom(CFont.ABO, size: Size.sizeMedium))
        }.foregroundStyle(color.mainCounter)
        
    }
}


struct lastRect: View {
    @Binding var UID:String
    @Binding var id:String
    @Binding var savingsStrings:[String]
    @Binding var savingsNumber:[Int]
    @Binding var savingsNumberStrings:[String]
    @Binding var title:String
    @Binding var date:Date
    @Binding var whichDays:[Int]
    @Binding var why:String
    
    @State var adSettings:Bool = false
    var geoHeight:CGFloat
    var body: some View {
        VStack(spacing: 50){
            VStack(spacing:10){
                Text("the day you began the struggle").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.mainEraser).fontWeight(.bold)
                Text(date.formatted(.dateTime.month().day().year().weekday())).foregroundStyle(color.white).font(.custom(CFont.AB, size: Size.sizeLarge))
            }
            color.white.frame(width: 250,height: 0.35).opacity(0.5)

            HStack(spacing: 50){
                NavigationLink(destination: vAdSettings(UID:$UID,savingsStrings: $savingsStrings, savingsNumber: $savingsNumber, savingsNumberStrings: $savingsNumberStrings, id: $id,whichDays: $whichDays, why: $why, date: $date, title: $title )){
                    customButtonLR(image: "gearshape.fill", title: "settings")
                }
                customButtonLR(image: "square.and.arrow.up.fill", title: "share")
            }
        }.frame(maxWidth: .infinity,minHeight: geoHeight / 2.35).background(color.main.gradient).cornerRadius(30).padding(30).shadow(radius: 12)

    }
}
struct VASText: View {
    @State var font:String
    @State var title:String
    @State var color:Color
    var body: some View {
        Text(title).font(.custom(font, size: Size.sizeLarge)).foregroundStyle(color)
    }
}
struct reset: View {
    @StateObject var SolidManager = solidManager()
    @Binding var date:Date
    @Binding var id:String
    @Binding var alert:Bool
    @State var loading:Bool = false
    @Binding var info:Bool
    @Binding var errorInfo:Bool
    var body: some View {
        ZStack{
            Button(action: {
                alert = true
            }, label: {
                HStack{
                    VASText(font: CFont.ABO, title: "reset",color:.red)
                    if(loading){
                        Spacer()
                        ProgressView()
                    }
                }
                
            })
            .alert(isPresented: $alert) {
                Alert(title: Text("Warning"),
                      message: Text("Are you sure the day will reset?"),
                      primaryButton: .default(Text("reset"), action: {
                    Task{
                        loading = true
                        alert = false
                        do{
                            try await SolidManager.reset(id: id)
                            date = Date()
                            info = true
                            loading = false
                        }catch{
                            loading = false
                            errorInfo = true
                        }
                    }
                }),
                      secondaryButton: .cancel(Text("cancel")))
            }
        }

        
        
    }
}
struct vAdSettings: View {
    @Binding var UID:String
    @Binding var savingsStrings:[String]
    @Binding var savingsNumber:[Int]
    @Binding var savingsNumberStrings:[String]
    @Binding var id:String
    @Binding var whichDays:[Int]
    @Binding var why:String
    @Binding var date:Date
    @Binding var title:String
    @State var alert:Bool = false
    @State var infoAlert:Bool = false
    @State var errorInfoAlert:Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack{
            ZStack{
                List{
                    NavigationLink(destination: vSaveSettings(UID:$UID,id: $id, savingsStrings: $savingsStrings, savingsNumber: $savingsNumber, savingsNumberStrings: $savingsNumberStrings,whichDays:$whichDays)){
                        VASText(font: CFont.ABO, title: "savings", color: color.dark)
                    }
                    NavigationLink(destination: vAdSettingsM(UID:$UID,why: $why, id: $id)){
                        VASText(font: CFont.ABO, title: "motivational sentence", color: color.dark)
                    }
                    Section(){
                    
                        reset(date: $date, id: $id, alert: $alert,info:$infoAlert, errorInfo: $errorInfoAlert)
                    }

                   
                    
                }
            }.toolbar{
                ToolbarItem(placement: .principal){
                    VStack{
                        
                        VASText(font: CFont.ABO, title:"\(title) Addiction",color:color.dark).fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left").foregroundStyle(color.dark).fontWeight(.semibold)
                    }
                }
            }.alert(isPresented: $infoAlert) {
                Alert(title: Text("Information"),
                      message: Text("Reset\nIf you are feeling down you can visit the motivation on the addiction page..."),
                      dismissButton: .default(Text("Tamam")))
            }.alert(isPresented: $errorInfoAlert) {
                Alert(title: Text("Error"),
                      message: Text("Reset Failed\nCheck your internet connection or try again later..."),
                      dismissButton: .default(Text("OK.")))
            }
        }.navigationBarBackButtonHidden()
    }
}

struct vSaveSettings:View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var whichDaysController:Bool = false
    @State var loading:Bool = false
    @State var openReNewest:Bool = false
    @StateObject var SolidManager = solidManager()
    @State var showSetupSaving:Bool = false
    @Binding var UID:String
    @Binding var id:String
    @Binding var savingsStrings:[String]
    @Binding var savingsNumber:[Int]
    @Binding var savingsNumberStrings:[String]
    @Binding var whichDays:[Int]
    @State var savingsStringsUpdate:[String] = []
    @State var savingsNumberUpdate:[Int] = []
    @State var savingsNumberStringsUpdate:[String] = []
    @State var suggTitles:[String] = ["money","time","calories"]

    var body: some View {
        NavigationStack{
            ZStack{
                List{
                    Section(header: Text("Suggestions")){
                        
                        customCreaterButtonDSP(savingsStrings: $savingsStringsUpdate, savingsNumber: $savingsNumberUpdate, savingsNumberStrings: $savingsNumberStringsUpdate, controlArray: savingsStringsUpdate, text: "money")
                        
                        customCreaterButtonDSP(savingsStrings: $savingsStringsUpdate, savingsNumber: $savingsNumberUpdate, savingsNumberStrings: $savingsNumberStringsUpdate, controlArray: savingsStringsUpdate, text: "time")
                        
                        customCreaterButtonDSP(savingsStrings: $savingsStringsUpdate, savingsNumber: $savingsNumberUpdate, savingsNumberStrings: $savingsNumberStringsUpdate, controlArray: savingsStringsUpdate, text: "calories")
                        
                    }
                    Section(header: Text("special")){
                        customCreaterButtonDSP(savingsStrings: $savingsStringsUpdate, savingsNumber: $savingsNumberUpdate, savingsNumberStrings: $savingsNumberStringsUpdate, controlArray: [], text: "create")
                    }
                    
                    ForEach(savingsStringsUpdate,id:\.self){ value in
                        if !suggTitles.contains(value){
                            
                            Section(header: Text("your creations")){
                                Button(action: {
                                    
                                    if let cValue = savingsStringsUpdate.firstIndex(of: value){
                                        savingsStringsUpdate.remove(at: cValue)
                                        savingsNumberUpdate.remove(at: cValue)
                                        savingsNumberStringsUpdate.remove(at: cValue)
                                    }
                                }){
                                    HStack {
                                        Text(value).foregroundColor(color.dark).font(.custom(CFont.ABO, size: Size.sizeLarge))
                                        Spacer()
                                        Image(systemName: "trash").foregroundColor(.red).font(.system(size: Size.sizeLarge + 2))
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    VASText(font: CFont.ABO, title: "vazgeç",color:color.dark).onTapGesture {
                        
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }
                }
                if(savingsStringsUpdate != savingsStrings && !loading){
                    
                    ToolbarItem(placement: .topBarTrailing){
                        VASText(font: CFont.ABO, title: "apply",color: color.main)
                            .fontWeight(.heavy)
                            .onTapGesture {
                                loading = true
                                Task{
                                    do{
                                        try await SolidManager.setupSave(UID: UID,id: id, savingsStrings: savingsStringsUpdate, savingsNumber: savingsNumberUpdate, savingsNumberStrings: savingsNumberStringsUpdate)
                                        savingsNumber = savingsNumberUpdate
                                        savingsStrings = savingsStringsUpdate
                                        savingsNumberStrings = savingsNumberStringsUpdate
                                        self.presentationMode.wrappedValue.dismiss()
                                        
                                    }
                                    catch{
                                        
                                    }
                                }
                            }
                    }
                }else if(loading){
                    ToolbarItem(placement: .topBarTrailing){
                        ProgressView()
                    }
                }
            }
            .onAppear{
                savingsStringsUpdate = savingsStrings
                savingsNumberStringsUpdate = savingsNumberStrings
                savingsNumberUpdate = savingsNumber
                
                if whichDays.isEmpty {whichDaysController = true}
               
                
            }
            .sheet(isPresented: $whichDaysController){
                vAdSettingsWD(UID:$UID,id: $id, whichDays: $whichDays).environment(\.colorScheme, .light).presentationCornerRadius(10).presentationDetents([.height(300)]).interactiveDismissDisabled()
            }
            
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    vAdSettings(UID:.constant(""),savingsStrings: .constant(["para","kağıt"]), savingsNumber: .constant([10,20]), savingsNumberStrings: .constant(["$","adet"]), id: .constant(""), whichDays: .constant([1]), why: .constant(""), date: .constant(Date()), title: .constant("Smoke"))
}
struct vAdSettingsM: View {
    @FocusState var focused:Bool
    @StateObject var SolidManager = solidManager()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var UID:String
    @Binding var why:String
    @Binding var id:String
    @State var loading:Bool = false
    @State var text:String = ""
    var body: some View {
        NavigationStack{
            ZStack{
                List{
                    Section(header:Text("Your Motivational Phrase").textCase(.lowercase).padding(.top,30)){
                        TextField("...", text: $text).focused($focused)
                    }
                    .font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.dark)
                    
                    Section(header:Text("inspirational phrases").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.dark.opacity(0.6)).textCase(.lowercase).padding(.top,20)){
                        VStack(alignment: .leading,spacing: 15){
                            Text("✎ How do you imagine your life without addiction?")
                            Text("✎ What did your addiction cost you?")
                            Text("✎ In which moments do you most want to return to your addiction?")
                            Text("✎ What are your dreams that stand in the way of addiction?")
                            Text("✎ What would your biggest supporter say to you?")
                        }.padding(.vertical).font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.dark.opacity(0.6))
                    }
                }
                .listStyle(.grouped)
            }.toolbar{
                ToolbarItem(placement: .topBarLeading){
                    VASText(font: CFont.ABO, title: "cancel",color:color.dark).onTapGesture {
                        
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        Task{
                            loading = true
                            do{
                                try await SolidManager.setupWhy(UID:UID,id: id, why: text)
                                why = text
                                presentationMode.wrappedValue.dismiss()
                            }catch{
                                
                            }
                        }
                    }, label: {
                        if(!loading){
                            VASText(font: CFont.ABO, title: "update",color:color.main).fontWeight(.semibold)
                        }else{
                            ProgressView()
                        }
                        
                    }).disabled(loading || text.isEmpty)
                  
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear{
                focused = true
            }
        }
    }
}

#Preview {
    vAdSettingsM(UID:.constant(""),why: .constant(""),id:.constant(""))
}

struct vAdSettingsWD: View {
    @Binding var UID:String
    @Binding var id:String
    @Binding var whichDays:[Int]

    var body: some View{
        stTwo(UID:$UID,id: $id, whichDays: $whichDays)
    }
}
struct stTwo: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var SolidManager = solidManager()
    @State var loading:Bool = false
    @State var days:[String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @State var days2:[String] = ["Prşmbe","Cuma","Cmrtesi"]
    @State var days3:[String] = ["Pazar"]
    @State var whichDaysUS:[Int] = []
    @Binding var UID:String
    @Binding var id:String
    @Binding var whichDays:[Int]
    var body: some View {
        
        NavigationStack{
            ZStack{
                VStack(spacing:12){
                    Spacer()
                    VStack(alignment: .leading,spacing:0){
                        Text("'the days when I surrendered to my addiction'").font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.regular).foregroundStyle(color.dark).padding(.horizontal)
                        ScrollView(.horizontal){
                            HStack(spacing:18){
                                ForEach(0...6,id:\.self){ index in
                                    RoundedRectangle(cornerRadius: 5 ).fill( whichDaysUS.contains(index) ? color.main : color.white).shadow(color: whichDaysUS.contains(index) ? color.main : color.dark,radius:0.7).frame(width: 90,height: 35).overlay{
                                        Text(days[index]).font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundColor(whichDaysUS.contains(index) ? color.white : color.dark.opacity(0.7))
                                    }.onTapGesture {
                                        if let indexL = whichDaysUS.firstIndex(of: index){
                                            
                                            whichDaysUS.remove(at: indexL)
                                        }else{
                                            withAnimation{
                                                whichDaysUS.append(index)
                                            }
                                        }
                                        
                                    }
                                }
                            }.padding(.vertical,30).padding(.horizontal)
                        }
                    }
                    Spacer()
                }
            }.toolbar{
               
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        Task{
                            loading = true
                            do{
                                try await SolidManager.setupWD(UID:UID,id: id, whichDays: whichDaysUS)
                                whichDays = whichDaysUS
                                self.presentationMode.wrappedValue.dismiss()
                                
                            }catch{
                                
                            }
                        }
                    }, label: {
                        
                        Circle().fill(.white).frame(width:40,height:40).shadow(radius: 2).overlay{
                            if(loading){
                                ProgressView()
                            }else{
                                Image(systemName: "checkmark").foregroundStyle(color.main).fontWeight(.bold)
                            }
                        }
                    }).padding(.top,30).disabled(loading || whichDaysUS.isEmpty)
                  

                }
            }
        }
    }
}

struct saveRect: View {
    @Binding var whichDays:[Int]
    @Binding var Date:Date
    @Binding var saveStrings:[String]
    @Binding var saveInt:[Int]
    @Binding var saveIntStrings:[String]
    
    var geoHeight:CGFloat
    var body: some View {
        VStack{
            saveRectInside(whichDays: $whichDays, Date: $Date, saveStrings: $saveStrings, saveInt: $saveInt, saveIntStrings: $saveIntStrings)
        }
        .frame(maxWidth: .infinity,maxHeight: geoHeight / 2.35)
        .background(color.main.gradient)
        .cornerRadius(30)
        .padding(30)
        .shadow(radius: 12)

    }
}

struct customCreaterButtonDSP:View{
    
    @Binding var savingsStrings:[String]
    @Binding var savingsNumber:[Int]
    @Binding var savingsNumberStrings:[String]

    @State var sheetHeight:CGFloat = .zero
    @State var showSetupSaving:Bool = false
    var controlArray:[String]
    var text:String
    var body: some View{

        Button(action: {
            if let index = savingsStrings.firstIndex(of: text){
                savingsStrings.remove(at: index)
                savingsNumber.remove(at: index)
                savingsNumberStrings.remove(at: index)
            }else{
                
               
                showSetupSaving.toggle()
            }
        }, label: {
            HStack {
                Text(text).foregroundColor(color.dark).font(.custom(CFont.ABO, size: Size.sizeLarge))
                Spacer()
                Image(systemName: controlArray.contains(text) ? "trash" : "plus").foregroundColor(controlArray.contains(text) ? .red : color.main).font(.system(size: Size.sizeLarge + 2)).fontWeight(controlArray.contains(text) ? .regular : .regular)
            }
        }).padding(.vertical,6).foregroundColor(color.main)
            .fullScreenCover(isPresented: $showSetupSaving){
                setupSave(savingsStrings: $savingsStrings, savingsNumber: $savingsNumber, savingsNumberStrings: $savingsNumberStrings, titleRoad: text).environment(\.colorScheme, .light)
            }
        
    }
}

struct mainRec: View {
    @StateObject var entry = entryManager()
    @ObservedObject var x = savingsDateManager()
    @State var stageD:adictionStage = .awareness
    @State var stagePageShow:Bool = false
    @Binding var date:Date
    @Binding var showInfoPage:Bool
    @Binding var title:String
    @Binding var day:Int
    @Binding var stage:Int
    
    @Binding var po1:Bool
    @Binding var po2:Bool
    @State var percentUS:Int = 0
    var geoHeight:CGFloat
    var body: some View {
        VStack{
            
            VStack(spacing: 40){
                
                
                VStack(spacing: 10){
                    Text("\(title) Addiction").foregroundColor(color.mainEraser).font(.custom(CFont.ABO, size: Size.sizeMedium)).fontWeight(.heavy)
                    
                    Text("Day \(day)").foregroundColor(Color("N-Color00")).font(.custom("AvenirNext-Heavy", size: 35))
                }
                color.white.frame(width: 250,height: 0.35).opacity(0.5)
                
                NavigationLink(destination: stageP(stageD: $stageD, stage: $stage)){
                    VStack(spacing: 10){
                        
                        progressBarView(percent: CGFloat(percentUS))
                        
                        HStack(spacing: 4){
                            Text("stage - \(stage)")
                        }
                        .font(.custom("AvenirNext-Heavy", size: Size.sizeLarge))
                        .foregroundStyle(color.mainCounter)

                    }.popover(isPresented: $po1,attachmentAnchor: .point(.top),arrowEdge: .bottom){
                        VStack{
                            Text("click and get information")
                        }.foregroundStyle(color.dark)
                        .padding(.horizontal).presentationCompactAdaptation(.popover)
                    }.popover(isPresented: $po2,attachmentAnchor: .point(.bottomTrailing),arrowEdge: .top){
                        VStack{
                            Image(systemName: "hand.draw.fill").scaleEffect(x:-1,y:1)
                                .rotationEffect(.degrees(-15))
                                .font(.system(size: 25))
                            Text("slide for savings")
                        }.foregroundStyle(color.dark)
                        .padding(.horizontal).presentationCompactAdaptation(.popover)
                    }

                }
            }
            .padding()
            .background(.clear)
        }
        .frame(maxWidth: .infinity,minHeight: geoHeight / 2.35)
        .background(color.main.gradient)
        .cornerRadius(30)
        .padding(30)
        .shadow(radius: 12)
        .onAppear{
            stageD = entry.entryStageMath(actualDay: day).2

            // 7  ---  11   (20)
            withAnimation(.easeInOut(duration: 2.4)){
                percentUS = ((100 / stageD.leftDay) * day)
                //percentUS = (100 / (entry.entryStageMath(actualDay: day).1 - entry.entryStageMath(actualDay: day).3 + 1)) * (day - entry.entryStageMath(actualDay: day).3)
            }
            
        }
    }
}
struct mainRecInside:View {
    @Binding var sEntryPage:Bool
    var body: some View {
        VStack{
            Text("a")
        }
    }
}

struct stagePagePieceStage: View {
    var stage:Int
    var body: some View {
        Text("Stage \(stage)").font(.custom(CFont.AB, size: Size.sizeUltraLarge)).foregroundStyle(color.mainCounter)
    }
}
struct stagePagePieceDay:View {
    var stageD:adictionStage
    var body: some View {
        Text("[ Day \(stageD.day) ]")
            .font(.custom(CFont.ABO, size: Size.sizeMedium))
            .opacity(0.5)
            .foregroundStyle(color.white)
            .fontWeight(.heavy)
    }
}
struct stagePagePieceTitle:View {
    var stageD:adictionStage
    var body: some View{
        HStack{
            Image(systemName: "laurel.leading").font(.system(size: 35)).fontWeight(.regular).foregroundStyle(color.white).opacity(0.5)
            
            Text("\(stageD.title)").font(.custom(CFont.AH, size: Size.sizeLarge)).foregroundStyle(color.white).opacity(0.6)
            
            Image(systemName: "laurel.trailing").font(.system(size: 35)).fontWeight(.regular).foregroundStyle(color.white).opacity(0.5)
        }
    }
}
struct stagePagePieceInfo: View {
    
    var stage:Int
    
    @Binding var number:Int
    var body: some View {
        
        VStack(spacing:15){
            Text("\(NSLocalizedString(number == 0 ? "specialTitle-\(number)" : "specialTitle-\(stage)-\(number)", comment: ""))")
                .multilineTextAlignment(.center)
                .font(.custom(CFont.AM, size: Size.sizeLarge))
                .padding(.horizontal,20)
            
            
            Text("\(NSLocalizedString(number == 0 ? "special-\(number)" : "special-\(stage)-\(number)", comment: ""))")
                .multilineTextAlignment(.center)
                .font(.custom(CFont.ABO, size: Size.sizeLarge))
                .padding(.horizontal,20)
            if(number == 0){
                Image(systemName: "arrow.down.circle.dotted")
                    .font(.system(size: Size.sizeLarge + 6))
            }
            
        }.foregroundStyle(color.dark)
        
    }
}
struct stagePagePieceBox:View {
    @Binding var boxNumber:Int
    var body: some View {
        HStack(spacing:40){
            ForEach(1...3,id:\.self){ index in
                Button(action: {
                    withAnimation{
                        boxNumber = index
                    }
                }){
                    Image(systemName: boxNumber != index ? "shippingbox" : "shippingbox.fill")
                        .font(.system(size: Size.sizeUltraLarge)).foregroundStyle(color.dark)
                }
            }
        }
    }
}
struct stageP: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var stageD:adictionStage
    @Binding var stage:Int
    
    @State var boxNumber:Int = 0
    @State var mode:Bool = false
    
    var body: some View {
        NavigationStack{
            GeometryReader{ geo in
                VStack{
                    VStack(spacing:40){
                        
                        VStack(spacing:2){
                            stagePagePieceStage(stage: stage)
                            stagePagePieceDay(stageD: stageD)
                        }.padding(.top,geo.size.height / 21)
                        
                        stagePagePieceTitle(stageD: stageD)
                        Spacer()
                    }.frame(width:geo.size.width,height: geo.size.height / 2.5).background(color.main.gradient)
                    
                    Spacer()
                    stagePagePieceInfo(stage: stage, number: $boxNumber)
                    Spacer()
                    
                    
                }.frame(maxWidth: .infinity,maxHeight: .infinity).background(.white)
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left").font(.system(size: Size.sizeLarge)).fontWeight(.bold).foregroundStyle(color.mainCounter)
                    }
                }
                ToolbarItem(placement: .bottomBar){
                    stagePagePieceBox(boxNumber: $boxNumber)
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    stageP(stageD: .constant(.awareness), stage: .constant(1))
}

struct saveRectInside:View {
    
    @ObservedObject var x = savingsDateManager()

    @Binding var whichDays:Array<Int>
    @Binding var Date:Date
    @Binding var saveStrings:[String] //["para","zaman","kalori"]
    @Binding var saveInt:[Int]
    @Binding var saveIntStrings:[String]
    
    
    @State private var selectedIndex: Int = 0
        @State private var selectedNumberTitle: String = ""
        @State private var selectedNumber: Int = 0
        
    
    var body: some View {
        
        
        
        
        VStack(spacing: 20) {
            
            VStack(spacing:0) {
                HStack{
                    
                    ForEach(0..<saveStrings.count, id: \.self) { index in
                        Button(action: {
                            withAnimation{
                                selectedIndex = index
                                selectedNumberTitle = saveIntStrings[index]
                                selectedNumber = saveInt[index]
                            }
                        }) {
                            Text(saveStrings[index])
                                .padding(20)
                                .background(Color.clear)
                                .foregroundColor(index == selectedIndex ? color.mainCounter : color.white)
                                .font(.custom(CFont.AB, size: Size.sizeMedium))
                            
                        }
                    }
                    
                    
                }
                
                color.white.frame(width: 250,height: 0.35).opacity(0.5)
            }
            Spacer()
            
            if(saveStrings.isEmpty){
                VStack(alignment: .center,spacing:30){
                    Text("You have no savings")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .foregroundStyle(color.mainEraser)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    VStack(spacing:15){
                        HStack(spacing:12){
                            
                            VStack{
                                Image(systemName: "hand.draw.fill").scaleEffect(x:-1,y:1)
                                    .rotationEffect(.degrees(-15))
                                    .font(.system(size: 25))
                                Text("slide")
                            }
                            Image(systemName: "arrow.right")
                            VStack{
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 25))
                                
                                Text("click")
                            }
                       
                            
                        }
                        Text("and add savings")
                    }.foregroundStyle(color.mainEraser)
                }
            }else{
                
                VStack(spacing:0) {
                    VStack(spacing:8) {
                        
                        Text("total savings").foregroundStyle(color.white).font(.custom(CFont.ABO, size: Size.sizeMedium))
                        
                        Text("\(selectedNumber * x.dateMath(date: Date, array: whichDays).1) \(selectedNumberTitle)").font(.custom("AvenirNext-Heavy", size: Size.sizeUltraLarge)).background(.clear).foregroundStyle(color.mainCounter)
                    }
                }
                
                HStack(spacing:70){
                    yearsORmounths(text: "monthly", cal: selectedNumber * (whichDays.count * 4) , SelectedNT: selectedNumberTitle)
                    
                    yearsORmounths(text: "annual", cal: selectedNumber * (whichDays.count * 52), SelectedNT: selectedNumberTitle)
                    
                }.foregroundStyle(color.mainEraser)
                
            }
        
            Spacer()
            
        }.onAppear{
            if !$saveStrings.isEmpty{
                selectedIndex = 0
                selectedNumber = saveInt[0]
                selectedNumberTitle = saveIntStrings[0]
            }
            
            
        }
    }
}

struct yearsORmounths: View {
    var text:String
    var cal:Int
    var SelectedNT:String
    var body: some View {
        Menu{
            Text("\(cal) \(SelectedNT)")
            
        }label: {
            
            VStack(spacing: 5) {
                
                Text(text).font(.custom(CFont.ABO, size: Size.sizeMedium)).fontWeight(.heavy)
                Image(systemName: "questionmark.circle")
            }.padding()
            
        }
    }
}

struct setupSave: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var savingsStrings:[String]
    @Binding var savingsNumber:[Int]
    @Binding var savingsNumberStrings:[String]
    
    @State private var formattedValue: String?
    
    @State var moneySymbol:[String] = ["","$","€","¥","£","CHF","NZ$","₺","RUB","AZN"]
    
    @State var timeSymbol:[String] = ["hour","minute"]
    
    @State var calorieSymbol:[String] = ["cal","kcal"]
    
    @State var onlySymbol:String = ""

    var titleRoad:String
    
    @State var amount:String = ""
    @State var title:String = ""
    @State var unit:String = ""
    
    var body: some View {
        NavigationStack {
            List{
                Section(header: Text("title").padding(.top,30)){
                    
                    if(titleRoad != "Create"){
                        Text(title).foregroundColor(color.dark.opacity(0.5))
                    }else{
                        TextField("", text: $title)
                    }
                    
                }
                
                Section(header: Text("Amount")){
                    TextField("",text: $amount).keyboardType(.numberPad)
                }
                
                Section(header: Text("unit")){
                    
                    if(titleRoad == "money"){
                        
                        Picker("Currency", selection: $onlySymbol) {
                            ForEach(moneySymbol,id:\.self) { value in
                                Text(value)
                            }
                        }.pickerStyle(.wheel).padding()
                        
                    }else if(titleRoad == "time"){
                        
                        Picker("Time Unit", selection: $onlySymbol) {
                            ForEach(timeSymbol,id:\.self) { value in
                                Text(value)
                            }
                        }.pickerStyle(.segmented).padding(10)
                        
                    }
                    
                    else if(titleRoad == "calories"){
                        
                        Picker("Calorie Unit", selection: $onlySymbol) {
                            ForEach(calorieSymbol,id:\.self) { value in
                                Text(value)
                            }
                            
                        }.pickerStyle(.segmented).padding(10)
                        
                    }else{
                        
                        Text(onlySymbol).foregroundColor(color.dark.opacity(0.5))
                        
                    }
                    
                }
            }.toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()

                    }){
                        Text("cancel").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.dark)
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        savingsStrings.append(title.lowercased())
                        savingsNumber.append(Int(amount) ?? 0)
                        savingsNumberStrings.append(onlySymbol)
                        presentationMode.wrappedValue.dismiss()

                    }){
                        Text("save").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.main)
                            .fontWeight(.semibold)
                        
                    }.disabled(title.isEmpty || onlySymbol.isEmpty || amount.isEmpty)
                }
              

            }
        }.onAppear{
            if(titleRoad != "create"){
                title = titleRoad
            }else{
                onlySymbol = "pieces"
            }
        }
    }
    
    func applyFormat(to newValue: String) -> String {
           let digits = newValue.filter { "0"..."9" ~= $0 }
           
           if let integer = Int(digits) {
               let formatter = NumberFormatter()
               formatter.numberStyle = .decimal
               return formatter.string(from: NSNumber(value: integer)) ?? ""
           }
           
           return ""
       }
}
