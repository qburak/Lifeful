//
//  firstLog.swift
//  twentyOneDay
//
//  Created by Burak on 21.10.2023.
//

import SwiftUI
import PhotosUI
struct firstTV: View {
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Build your profile").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.dark).fontWeight(.semibold)
            Text(" 🔧  🚧  🪚 ").font(.system(size: Size.sizeUltraLarge)).padding(.bottom,20)
            Text("click anywhere to continue").font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.heavy).foregroundStyle(color.dark).opacity(0.3)
            
        }.frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}


struct firstLog: View {
    

    @State var selectedPhoto: UIImage?

    @State private var selectedItem:PhotosPickerItem? = nil
    
    @Binding var viewModel:ProfileViewModel
    @Binding var userName:String
    @State var userUID:String = ""
    @State var image:UIImage?
    @State var imageControl:Bool = true
    @State var showImagePicker:Bool = false
    @State var numberArea:Int = 0
    @State var nick:String = ""
    @State var title:String = ""
    @State var start:Bool = false
    @State var loadForEnding:Bool = false
    var body: some View {
        NavigationStack{
            ZStack{
                TabView(selection: $numberArea){
                    firstTV().onTapGesture {
                        withAnimation{
                            numberArea += 1
                        }
                    }.tag(0)
                    
                    customerNick(placeholder: Text("nickname..."), text: $nick).padding(.leading,30).padding(.trailing,30).tag(1)
                    
                    ImageViewer(selectedPhoto: $selectedPhoto, selectedItem: $selectedItem).disabled(loadForEnding).tag(2)
                    
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                VStack(spacing: 15){
                    progressBarView(width: 200,percent:CGFloat(((numberArea) * 50)),color1:color.mainEraser,color2: color.main)
                    OptionalityTitleView(text: $title, number: $numberArea)
                    
                    if(numberArea == 1){
                        Button(action: {
                            withAnimation{
                                if(nick.count > 4){
                                    numberArea += 1
                                    hideKeyboard()
                                }
                            }
                        }, label: {
                            HStack{
                                Text("next").fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                                
                            }.foregroundStyle(nick.count > 4 ? color.main : color.mainEraser).font(.custom(CFont.ABO, size: Size.sizeLarge))
                                .padding()
                            
                        }).disabled(nick.count < 5)
                    }else if(numberArea == 2){
                        if(!loadForEnding){
                            Button(action: {
                                Task{
                                    loadForEnding = true
                                    
                                    if let ACImage = selectedPhoto{
                                        if let user = viewModel.user{
                                            do{
                                                
                                                try await UserManager.shared.userProfileData(userProfileData: DBProfileData(nickName: nick, photoPath: "nil",profileEntry: 0,profileSol: 0, profileEntryLike: 0, blocks: [],ban:false), userUID: user.userId)
                                                
                                                do{
                                                    
                                                    try await viewModel.saveProfileImage(item: selectedItem!, UID: user.userId, isSuccess: $start)
                                                    
                                                    guard let imageData = try? await selectedItem!.loadTransferable(type: Data.self) else { return }
                                                    
                                                }catch{
                                                    
                                                }
                                                
                                            }catch{
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            }, label: {
                                Text("finish").foregroundStyle(selectedPhoto == nil ? color.main.opacity(0.45) : color.main).fontWeight(.semibold).font(.custom(CFont.ABO, size: Size.sizeLarge))
                                    .padding(20)
                            }).disabled(selectedPhoto == nil)
                        }else{
                            ProgressView()
                        }

                    }
                    Spacer()
                }.padding(.top,25)
            }
        }.fullScreenCover(isPresented: $start){
            rootView(ST: .constant(.house)).environment(\.colorScheme, .light)
        }.onAppear{
            UIScrollView.appearance().isScrollEnabled = false
            if let x = viewModel.user?.userNick{
                nick = x
            }
        }
    }
    func nextButton(){
        
    }
}

#Preview {
    firstLog(viewModel: .constant(ProfileViewModel()),userName: .constant(""))
}
struct ImageViewer:View{
    @Binding var selectedPhoto: UIImage?
    @Binding var selectedItem:PhotosPickerItem?
    
    var body: some View{
        VStack {
            
            Rectangle().fill(.white).frame(width:90,height: 90).overlay(
                VStack{
                    PhotosPicker(selection: $selectedItem,matching: .images, photoLibrary: .shared()){
                        if let photo = selectedPhoto {
                            Image(uiImage: photo)
                                .resizable().scaledToFill().frame(width:90,height: 90).cornerRadius(75).shadow(radius: 2)
                        }else{
                            Image(systemName: "person.fill").foregroundColor(color.main).scaleEffect(2)
                        }
                    }
                }
            ).cornerRadius(60).shadow(radius: 2).onTapGesture {
                
            }
        }.onChange(of: selectedItem) { newValue in
            
            if let newValue {
                Task {
                    
                    guard let imageData = try? await newValue.loadTransferable(type: Data.self) else { return }
                            
                            // Create a UIImage object from the imageData.
                            selectedPhoto = UIImage(data: imageData)
                }
            }
        }
    }
}
struct ImageView:View{
    @Binding var showImagePicker:Bool
    @Binding var image:UIImage?
    @Binding var nick:String
    
    var body: some View{
        VStack {
            Rectangle().fill(.white).frame(width:90,height: 90).overlay(
                VStack{
                    if let image = self.image {
                        Image(uiImage: image).resizable().scaledToFill().frame(width: 90,height: 90).cornerRadius(64)
                    }else{
                        Image(systemName: "person.fill").foregroundColor(color.main).scaleEffect(2)
                    }
                }
            ).cornerRadius(60).shadow(radius: 2).onTapGesture {
                showImagePicker.toggle()
            }
        }
    }
}

struct OptionalityTitleView: View {
    @Binding var text: String
    @Binding var number: Int

    var body: some View {
        Text(titleText)
            .font(.custom(CFont.ABO, size: Size.sizeLarge))
            .foregroundStyle(color.dark)
            .fontWeight(.semibold)
            .onAppear {
                updateText()
            }
    }

    private var titleText: String {
        switch number {
        case 0:
            return "Welcome"
        case 1:
            return "Profile Nickname"
        case 2:
            return "Profil Picture"
        default:
            return ""
        }
    }

    private func updateText() {
        text = titleText
    }
}

struct customerNick:View{
    var placeholder:Text
    
    @Binding var text:String
    var editingChanged:(Bool) -> () = {_ in}
    var commit:() -> () = {}
    @FocusState var focused:Bool
    
    var body: some View{
        VStack(spacing: 5) {
            
            HStack{
                Spacer()
                Text("\(12 - text.count)").font(.custom(CFont.AB, size: Size.sizeLarge)).foregroundStyle(color.dark.opacity(0.25))
            }.padding(.trailing,4)
            ZStack(alignment: .leading){
                
                HStack {
                    TextField("nickname...",text:$text,axis: .vertical).font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundStyle(color.dark).textFieldStyle(.roundedBorder).focused($focused).background(.clear).onChange(of: text){ newValue in
                        if newValue.count > 12{
                            text = String(newValue.prefix(12))
                        }
                    }
                }
               
                
            }
           
            HStack {
                Text("✎  Must be between 4-12 characters").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundColor(.black.opacity(0.4))
                Spacer()
            }.padding(.top,30)
        }.onAppear{
            focused = true
        }
    }
    
}

