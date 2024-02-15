
import SwiftUI
import PhotosUI
struct editProfile: View {
    @Binding var UID:String
    @StateObject private var viewModel = ProfileViewModel()
    @State var apply:Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var back:Bool
    @State private var selectedItem:PhotosPickerItem? = nil
    @State var fixText:String = ""
    @State var text:String = ""
    @State var selectedPhoto: UIImage?
    @State var newPhoto:Bool = false
    //@State var selectedSecondPhoto:UIImage?
    @State var isEditing:Bool = false
    @State var id:String = ""
    @State var photoPathUpdate:String = ""
    @State var loadForEnding:Bool = false
    var body: some View {
        
        
        NavigationView {
            
            List{
                
                VStack(spacing: 0) {
                    if let photo = selectedPhoto {
                        Image(uiImage: photo)
                            .resizable().scaledToFill().frame(width:90,height: 90).cornerRadius(75).shadow(radius: 2)
                    }else{
                        imageASYNC(photoPath: photoPathUpdate)
                    }
                    
                    
                    Button(action: {
                        
                    }){
                        PhotosPicker(selection: $selectedItem,matching: .images, photoLibrary: .shared()){
                            Text("Edit").foregroundColor(color.main)
                        }.disabled(loadForEnding || isEditing)
                        
                    }.padding(.top,20)
                    
                }.opacity(isEditing ? 0.65 : 1).onChange(of: selectedItem) { newValue in
        
                    if let newValue {
                        Task {
                            
                            guard let imageData = try? await newValue.loadTransferable(type: Data.self) else { return }
                                    
                                    // Create a UIImage object from the imageData.
                                    selectedPhoto = UIImage(data: imageData)
                                
                            newPhoto = true
                            
                        }
                    }
                }.padding()
                
                VStack {
                    TextField("username", text: $text).onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
                    Divider()
                }.padding()
            }.toolbar{
                
                if(newPhoto){
                    if(!loadForEnding){
                        ToolbarItem(placement: .topBarTrailing){
                            CustomToolbar(fColor: color.main,
                                          toolTitle: "apply",
                                          toolImage: "",
                                          action: {
                                Task{
                                    loadForEnding = true
                                    do{
                                        try await viewModel.deleteImage(UID: UID)
                                        do{
                                            try await viewModel.saveProfileImage(item: selectedItem!,UID:UID, isSuccess: $apply)
                                            
                                            
                                            guard let imageData = try? await selectedItem!.loadTransferable(type: Data.self) else { return }
                                            
                                            
                                            selectedPhoto = UIImage(data: imageData)
                                            
                                        }catch{
                                            
                                        }
                                    }catch{
                                        
                                    }
                                }
                                
                            })
                          
                        }
                        ToolbarItem(placement: .topBarLeading){
                            CustomToolbar(fColor: color.dark,
                                          toolTitle: "cancel",
                                          toolImage: "",
                                          action: {
                                selectedPhoto = nil
                                newPhoto = false
                                
                            })
                          
                        }
                    }else{
                        ToolbarItem(placement: .topBarTrailing){
                            ProgressView()
                        }
                    }
                }else{
                    
                    if !isEditing {
                        ToolbarItem(placement: .navigationBarLeading) {
                            CustomToolbar(fColor: color.main,
                                          toolTitle: "",
                                          toolImage: "chevron.left",
                                          action: {
                                back.toggle()
                            })
                        }
                        
                        
                    }else{
                        ToolbarItem(placement: .navigationBarLeading) {
                            CustomToolbar(fColor: color.dark,
                                          toolTitle: "cancel",
                                          toolImage: "",
                                          action: {
                                text = fixText
                                hideKeyboard()
                                isEditing = false
                                
                            })
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                Task{
                                    do{
                                        try await UserManager.shared.updateEditUserNickName(userUID:id,nickName: text.lowercased())
                                        UserDefaults.standard.set(text.lowercased(), forKey: "nickName")
                                        hideKeyboard()
                                        isEditing = false
                                        apply = true
                                    }catch{
                                        
                                    }
                                    
                                }
                            }){
                                Text("over").foregroundColor(color.main).font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.semibold)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .fontWeight(.semibold)
                        .foregroundStyle(color.dark)
                        
                }
                
                
                
            }.onAppear{
                id = UserDefaults.standard.string(forKey: "userUIDD") ?? "X"
                text = UserDefaults.standard.string(forKey: "nickName") ?? "vXant"
                fixText = UserDefaults.standard.string(forKey: "nickName") ?? "vXant"
                photoPathUpdate = UserDefaults.standard.string(forKey: "photoPath") ?? "A"
            }.task {
                try? await viewModel.loadCurrentUser()
            }.fullScreenCover(isPresented: $apply, content: {
                rootView(ST: .constant(.person)).environment(\.colorScheme, .light)
            })
        }.navigationBarBackButtonHidden()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct editProfile_Previews: PreviewProvider {
    static var previews: some View {
        editProfile(UID: .constant(""), back: .constant(false))
    }
}
struct imageASYNC:View{
    var photoPath:String = ""
    var body: some View{
        
        AsyncImage(url: URL(string: photoPath)){ image in
            image.resizable().scaledToFill().frame(width:90,height: 90).cornerRadius(75).shadow(radius: 2)
            
        } placeholder: {
            Circle().fill(.white).frame(width: 90,height: 90).shadow(radius: 2).overlay(
                ProgressView().frame(width: 90,height: 90)
            )
        }
        
    }
}
struct CustomToolbar: View {
    var fColor: Color
    var toolTitle: String
    var toolImage: String
    var action: () -> Void
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 0) {
                Image(systemName: toolImage)
                    
                    
                Text(toolTitle)
            }.font(.custom(CFont.ABO, size: Size.sizeLarge))
                .fontWeight(.semibold)
                .foregroundColor(fColor)
        }
    }
}

