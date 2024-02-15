//
//  settingsPage.swift
//  twentyOneDay
//
//  Created by Burak on 12.09.2023.
//

import SwiftUI

@MainActor
final class SettingsViewModel:ObservableObject{
    
    @Published var authUser: AuthDataResultModel? = nil

    func signOut() throws {
       try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws{
        try await AuthenticationManager.shared.delete()
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
}

struct settingsPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var showInLogPage:Bool
    @StateObject var viewModel = SettingsViewModel()
    @StateObject var viewModelF = solidManager()
    @Binding var UID:String
    @Binding var UTDBlocks:[String]

    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: Blocked(UTDBlocks: $UTDBlocks,UTDId:$UID)){
                    Text("Blocked")
                }
                
              
                
                
               
               
                Section{
                    Button(action: {
                        if let url = URL(string: "https://dictionapp.wordpress.com/2023/11/20/lifeful-privacy-policy/") {
                            UIApplication.shared.open(url)
                        }
                    }){
                        Text("Privacy Policy")
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://dictionapp.wordpress.com/2023/11/20/lifeful-terms-of-use/") {
                            UIApplication.shared.open(url)
                        }
                        
                    }){
                        Text("Terms of Use")
                    }
                    
                }.foregroundStyle(color.main)
                
                Section{
                    Button(action: {
                        Task{
                            do{
                                try viewModel.signOut()
                                showInLogPage = true
                            }catch{
                                print(error)
                            }
                        }
                    }){
                        Text("Log Out").foregroundStyle(color.main)
                    }
                    
                    Button(role: .destructive, action: {
                        Task{
                            
                            do{
                                try await viewModelF.deleteAllData(UID: UID, subcollectionNames: ["profileData","solids"])
                                showInLogPage = true
                            }catch{
                                
                            }
                        }
                    }){
                        Text("Delete Account")
                    }
                    
                }
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }){
                        Image(systemName: "chevron.left").fontWeight(.semibold).foregroundColor(color.main)
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Settings")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .fontWeight(.semibold)
                        .foregroundStyle(color.dark)
                }
            }.onAppear{
                viewModel.loadAuthUser()
            }
        }
    }
}

struct settingsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            settingsPage(showInLogPage: .constant(false), UID: .constant("1234"), UTDBlocks: .constant(["*id*"]))
        }
    }
}
struct Blocked: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel = ProfileViewModel()
    @Binding var UTDBlocks:[String]
    @Binding var UTDId:String
    @State var loading:Bool = false
    @State var secondChooses:Bool = false
    var body: some View {
        NavigationStack{
            List{
                ForEach(UTDBlocks, id: \.self) { uid in
                    HStack{
                        VStack(alignment:.leading){
                            Text("\((viewModel.names[uid] ?? "Unknown")!)")
                            Text("\(uid)").fontWeight(.ultraLight).font(.custom(CFont.ABO, size: Size.sizeMedium))
                        }.font(.custom(CFont.ABO, size: Size.sizeLarge))
                        
                        Spacer()
                        
                        Button(action: {
                            Task{
                                loading = true
                                do{
                                    try await viewModel.unBlock(UTDId: UTDId, blockUID: uid)
                                    if let index = UTDBlocks.firstIndex(of: uid) {
                                        UTDBlocks.remove(at: index)
                                    }
                                    loading = false
                                    secondChooses = true
                                }catch{
                                
                                }
                                
                            }
                        }){
                            
                            Text("unblock")
                            
                        }.disabled(loading).foregroundStyle(loading ? .gray : color.main)

                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        print("A")
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left").foregroundStyle(loading ? .gray : color.main).fontWeight(.semibold)
                    }.disabled(loading)
                }
                if(loading){
                    ToolbarItem(placement: .topBarTrailing){
                        ProgressView()
                    }
                }
                
            }
            .task {
                viewModel.fetchNames(blockedUIDs: UTDBlocks)
            }
        } 
        .navigationBarBackButtonHidden(true)

    }
}
