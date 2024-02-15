//
//  searchPage.swift
//  twentyOneDay
//
//  Created by Burak on 14.10.2023.
//

import SwiftUI

struct searchPage: View {
    @Binding var UTDId:String
    @StateObject var SolidManager = solidManager()
    @State var text:String = ""
    @State var isEditing:Bool = false
    @State var joined:Bool = false
    @State var leaved:Bool = false
    @Binding var pojoin:Bool
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    ScrollView{
                        VStack(alignment: .leading,spacing: 60){
                            ForEach(SolidManager.solid){ data in
                                discoverView(UID: $UTDId, poJoin: $pojoin,id: data.id, idOriginal: data.id, title: data.title, person: data.person, urlLink: data.url, emoji: data.emoji,exp:data.exp, action: {
                                    
                                })
                            }
                        }
                    }
                }.toolbar{
                    ToolbarItem(placement: .principal){
                        HStack{
                            searchTextField(placeholder: Text("search"), width: geo.size.width / 1.5, isEditing: $isEditing, text: $text).onTapGesture {
                                withAnimation{
                                    isEditing.toggle()
                                }
                            }
                            
                        }
                    }
                    
                    
                }
            }.navigationBarBackButtonHidden()
                .task {
                    SolidManager.fetchNonMatchingSolids(userId: ID.userUID, prefix: text)
                }.onChange(of: text){ newValue in
                    SolidManager.fetchNonMatchingSolids(userId: ID.userUID, prefix: text)
                }
                                
        }
    }
}


struct searchTextField:View{
    @Environment(\.presentationMode) var presentationMode

    var placeholder:Text
    var width:CGFloat
    @Binding var isEditing:Bool
    @Binding var text:String
    var editingChanged:(Bool) -> () = {_ in}
    var commit:() -> () = {}
    
    var body: some View{
        HStack(spacing:0){
            if(!isEditing){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left").foregroundColor(color.dark).fontWeight(.semibold)
                })
            }
            
            
            HStack{
                
                TextField("search",text:$text,onEditingChanged:editingChanged,onCommit:commit)
                
                Image(systemName: "magnifyingglass").foregroundColor(color.dark).fontWeight(.regular)
                
            }.frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.vertical,10)
                .background(color.dark.opacity(0.058))
                .cornerRadius(12)
                .padding()
                .onTapGesture {
                    
                    withAnimation(.spring()){
                    isEditing = true
                }
            }
            if(isEditing){
                Button(action: {
                    text = ""
                    hideKeyboard()
                    withAnimation(.spring()){
                        isEditing = false
                    }
                }){
                    Text("cancel")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .foregroundStyle(color.dark)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
