//
//  mainPage.swift
//  twentyOneDay
//
//  Created by Burak on 8.08.2023.
//

import SwiftUI

struct mainPage: View {
    @State var sheetHeight:CGFloat = .zero
    @StateObject var viewModelEntry = SolEntryViewModel()
    @StateObject var viewModel = ProfileViewModel()
    @State var isItFirst:Bool = false
    @Binding var showInLogPage:Bool
    @ObservedObject var fireStore_House = dataManagers()
    @State var XS:String = "solidarity-adictions"
    @Environment(\.presentationMode) private var presentationMode
    @State var title:String = ""

    @State var showDetailPage:Bool = false
    @State var userID = "userID5"
    @State var or_aorr = true //Rutinlerim..Butonu değişim
    @State var or_lr_height:CGFloat = 200 //.house..Grup Rectangle'ın Yüksekliği
    @State var or_aorr_add:Bool = false //.add..Which One, Rutinlerim/Bağımlılıklarım
    @State var addOpenAlert:Bool = false
    @State var addOpen:Bool = false
    @State var or_updateDatas:Bool = false

    @State var SselectedTabBool:Bool = true
    
    @State private var selectedTab:Tab = .house
    
    @State var plusBoolean = false




    @State var rMotiHolder:[(String)] = []

    var body: some View {
        
        
        NavigationView {
            GeometryReader{ geometry in
                ZStack{
                    switch selectedTab {
                    case .house:
                       
                        VStack {
                            
                            VStack{
                                aorrbuttons(uChoose: {
                                    XS = or_aorr ? "solidarity-adictions":"solidarity-routins"
                                
                                },clickedChoose: $or_aorr)//ad.or.rout değişim sağlayan buton.
                                
                            }.frame(width:geometry.size.width,height: geometry.size.height / 8).background(.clear)
                       
                            Rectangle().fill(.white).frame(width:geometry.size.width / 1.2).cornerRadius(20).shadow(radius: 20).overlay(
                                ScrollView(.vertical){//sahip olunan gruplar burda listelenir yani görüntülenir.
                                    
                                    VStack {
                                        
                                        ForEach(fireStore_House.datas, id: \.id){ title in
                                            listingRectangle(lr_whichDays: .constant(title.whichDays), lr_height: $or_lr_height, lr_Title: .constant(title.id), lr_why: .constant(title.why),lr_Date: .constant(title.date), lr_SavingsTitles: .constant(title.savingsStrings),lr_SavingsNumber: .constant(title.savingsNumber),lr_SavingsNumberTitle: .constant(title.savingsNumberStrings), lr_Day: .constant(title.day),buttonAction: {showDetailPage.toggle()})
                                        }
                                    
                                     
                                    }.padding(.bottom,0).padding(.top,40)
                                    
                                }
                            )

                          
                        }.onAppear{
                            or_lr_height = geometry.size.height / 6
                          
                        }
                        
                    case .scroll:
                        VStack{//aramak istediği grup alanı değiştirildiğinde ona göre gruplar userdata2ile çekilir.
                            searchingButtons(selectedSTab: $SselectedTabBool)
                        
                            Rectangle().fill(.white).frame(width: geometry.size.width / 1.2,height: geometry.size.height / 1.14).background(Color.white).cornerRadius(20).shadow(radius: 10).overlay(
                                ScrollView(.vertical){//scroll'daki grupları gösterir
                                    VStack(spacing: 30){
                                     
                                    }.padding(.top,25).padding(.bottom,60)
                                }
                            )
                          
                        }.frame(width: geometry.size.width,height: geometry.size.height).background(Color.white).actionSheet(isPresented: $addOpenAlert){
                            ActionSheet(title: Text("Oluşturmak istediğin alan..."),message: nil,buttons: [
                                .default(Text("Bağımlılık"),action: {
                                    or_aorr_add = true
                                    addOpen.toggle()
                                }),
                                .default(Text("Rutin"),action: {
                                    or_aorr_add = false
                                    addOpen.toggle()
                                }),
                                .cancel(Text("İptal"))
                            ])
                        }
                        
                    case .person:
                        Text("person")
          
                    }
                }.background(Color(.white))
                
                customTabBar(selectedTab: $selectedTab) //ekranın altındaki butonlar...
                
            }.sheet(isPresented: $isItFirst, onDismiss: {
                
            },content: {
                firstLogin(viewModel: .constant(viewModel), isPresented: $isItFirst).presentationCornerRadius(20).presentationDetents(sheetHeight == .zero ? [.medium] :[.height(sheetHeight)])
            }).task{
                do{
                    try await viewModel.loadCurrentUser()
                    
                    if let pUser = viewModel.Puser{
                        UserDefaults.standard.setValue(pUser.photoPath, forKey: "photoPath")
                        UserDefaults.standard.setValue(pUser.nickName, forKey: "nickName")
                    }
                    
                    if let user = viewModel.user{
                        
                        UserDefaults.standard.set(user.userId, forKey: "userUIDD")
                      
                        UserManager.shared.userDataControl(uuid: user.userId) { exists in
                            if exists {
                                print("ProfileData collection exists.")
                            } else {
                                isItFirst = true
                            }
                        }
                    }
                    
                }catch{
                    print("buraya giriyor")
                }
               
               
            }
        }
    }
}


struct mainPage_Previews: PreviewProvider {
    static var previews: some View {
        mainPage(showInLogPage: .constant(false))
        
    }
}
