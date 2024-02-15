//
//  bannedPage.swift
//  twentyOneDay
//
//  Created by Burak on 30.11.2023.
//

import SwiftUI

struct bannedPage: View {
    @StateObject var viewModel = SettingsViewModel()
    @StateObject var SolidManager = solidManager()
    @State var showingAlert:Bool = false
    @State var email:String = ""
    @Binding var inLogPageShow:Bool
    @Binding var UTDId:String
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    Spacer()
                    Text("You're banned!").font(.custom(CFont.ABO, size: Size.sizeUltraLarge)).fontWeight(.medium)
                    Spacer()
                    
                    HStack(spacing:45){
                        Button(action: {
                            Task{
                                do{
                                    try viewModel.signOut()
                                    inLogPageShow = true
                                }
                            }
                        }){
                            Text("Log Out").padding(20)
                        }
                        
                        Button(action: {
                            showingAlert = true
                        }){
                            Text("Appeal").padding(20)
                        }
                    }
                    
                    Spacer()
                }.foregroundStyle(color.dark)
            }.alert("Enter your email", isPresented: $showingAlert) {
                TextField("Enter your email", text: $email)
                Button("Appeal & Log Out", action: submit)
            } message: {
                Text("Xcode will print whatever you type.")
            }
            .onAppear{
                viewModel.loadAuthUser()
            }
        }
    }
    func submit() {
        Task{
            do{
                try await SolidManager.sendAppeal(UTDId: UTDId, eMail: email)
                do{
                    try viewModel.signOut()
                    inLogPageShow = true
                }
            }catch{
                
            }
        }
    }
}

#Preview {
    bannedPage(inLogPageShow: .constant(false), UTDId: .constant(""))
}
