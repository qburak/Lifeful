//
//  sendEntry.swift
//  twentyOneDay
//
//  Created by Burak on 17.10.2023.
//

import SwiftUI

struct sendEntry: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var UTDPhoto:String
    @Binding var UTDId:String
    @Binding var day:Int
    @Binding var sol:String
    @Binding var stage:Int
    
    @FocusState var focused:Bool
    @State var updateEmoji:String = ""
    @State var updateString:String = ""
    @State var onlyEntry:String = ""
    @State var questionsEmoji:[String] = ["😁","😃","🙂","🙁","😔","😫"]
    @State var showIgnore:Bool = false

    @State var showAlert:Bool = false
    @State var loading:Bool = false


    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    VStack(spacing:10){
                        
                        HStack(spacing: 10){
                            entryProfilePhoto(url: UTDPhoto, onlySize: 33)
                            Menu{
                                ForEach(0...5,id:\.self){ index in
                                    Button(action: {
                                        showIgnore = false
                                        updateEmoji = questionsEmoji[index]
                                    }){
                                        Text(questionsEmoji[index])
                                    }
                                }
                            }label: {
                                HStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(color.white)
                                        .frame(width: 150,height: 30)
                                        .overlay{
                                            
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(updateEmoji.isEmpty ? color.main : color.mainCounter,lineWidth:1).overlay{
                                                    
                                                    ZStack{
                                                        Text(updateEmoji.isEmpty ? "mood" : updateEmoji)
                                                            .font(.custom(CFont.ABO, size: Size.sizeMedium))
                                                            .fontWeight(.semibold)
                                                        HStack{
                                                            Spacer()
                                                            Image(systemName: "chevron.down").padding(8)
                                                                
                                                        }
                                                        
                                                       
                                                    }.foregroundStyle(updateEmoji.isEmpty ? color.main : color.mainCounter)
                                                    
                                                }

                                       
                                        
                                    }
                                    
                                    
                                    
                                    Spacer()
                                }
                            }
                            
                        }
                        
                        TextField("how do you feel...", text: $onlyEntry,axis: .vertical).focused($focused).padding(.leading,42).foregroundStyle(color.dark).font(.custom(CFont.AM, size: Size.sizeLarge))
                        Spacer()
                    }.padding(.vertical,10)
                }.frame(height: geo.size.height)
                .navigationBarBackButtonHidden()
                .padding(19)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("cancel")
                                .font(.custom(CFont.ABO, size: Size.sizeLarge))
                                .fontWeight(.semibold)
                                .foregroundStyle(color.dark)
                                .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 15))
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {
                            if updateEmoji.isEmpty {
                                withAnimation{
                                    showAlert = true
                                }
                            }else{
                                loading = true
                                Task{
                                    try await SolEntryViewModel().sendData(text: onlyEntry, day: day, solidarityName: sol, stage: stage, emoji: updateEmoji,UTDId: UTDId)
                                    loading = false
                                    self.presentationMode.wrappedValue.dismiss()
                                    
                                }
                                
                            
                            }
                        }, label: {
                            RoundedRectangle(cornerRadius: 12).fill(color.main).frame(width: 120,height: 40).overlay{
                                if(loading){
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: color.white))
                                }else{
                                    Text("Share")
                                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                }
                        
                                
                            }.opacity(onlyEntry.isEmpty || updateEmoji.isEmpty ? 0.5 : 1)
                           
                        }).disabled(onlyEntry.isEmpty || loading)
                    }
                    ToolbarItem(placement: .principal){
                        
                         
                    }
                   
                }.alert(isPresented: $showAlert){
                    Alert(title: Text("Warning"), message: Text("you have to choose your mood to share."), dismissButton: .default(Text("OK.")) {
                        
                    })
                }
            }.onAppear{
                focused = true
            }
        }
    }
}

#Preview {
    sendEntry(UTDPhoto: .constant("a123"), UTDId: .constant("1234"), day: .constant(1), sol: .constant("aaa"), stage: .constant(1))
}
