//
//  messages.swift
//  twentyOneDay
//
//  Created by Burak on 8.08.2023.
//

import SwiftUI

struct messages: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var MessagesManager = messagesManager()
    
    @Binding var chatTitle:String
    @Binding var dayString:Int
    @Binding var solidImage:String
    @Binding var UTDId:String
    @Binding var UTDName:String
    @Binding var UTDBlocks:[String]
    @State var idm:String?
    @State var moreButtonS:Bool = true
    @State var lastCount:Int = 0
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing:0){
                    
                    ScrollViewReader{ reader in
                        
                        ScrollView{
                            VStack(spacing:7){
                                Button(action: {
                                    
                                    
                                    MessagesManager.loadMoreMessage(sol: chatTitle)
                                        
                                    if (lastCount == MessagesManager.messages.count){
                                        moreButtonS = false
                                    }else{
                                        lastCount = MessagesManager.messages.count
                                    }
                                }, label: {
                                    HStack{
                                        Text("load messages")
                                        Image(systemName: "arrow.up.to.line.compact")
                                    }.foregroundStyle(color.main)
                                        .font(.custom(CFont.ABO, size: Size.sizeLarge - 1))
                                        .padding(.bottom,-7)
                                }).opacity(MessagesManager.messages.count != 0 && MessagesManager.messages.count.isMultiple(of: 25) && moreButtonS ? 1 : 0)
                                
                                if(MessagesManager.messages.isEmpty){
                                    VStack(alignment:.center,spacing:35){
                                        
                                        Menu{
                                            Text("This conversation is so quiet that\nI hear my own echo.")
                                        }label: {
                                            Image(systemName: "tortoise.fill")
                                                .font(.system(size: 30))
                                                .foregroundStyle(color.main)
                                        }
                                       
                                            
                                       
                                        
                                        Text("No messages in the chat channel").fontWeight(.heavy).opacity(0.3)
                                        
                                        VStack(spacing:10){
                                            Text("be the first to write")
                                            Image(systemName: "arrow.down.circle.dotted")
                                                .font(.system(size: 30))
                                                
                                        }
                                    }
                                    .foregroundStyle(color.dark)
                                    .font(.custom(CFont.ABO, size: Size.sizeLarge))
                                    .padding(.horizontal,20)
                                    .padding(.top,25)
                                    
                                }
                                ForEach(Array(MessagesManager.messages.enumerated()), id: \.element.id) { index, message in
                                    if(!UTDBlocks.contains(message.uid)){
                                        if index > 0 {
                                            
                                            messageBubble(message: message, UTDId: $UTDId, UIDShow: .constant(MessagesManager.messages[index - 1].uid),UTDBlocks:$UTDBlocks,solName:chatTitle,delete:{
                                                
                                                Task{
                                                    do{
                                                        try await MessagesManager.deleteMessageHide(sol: chatTitle, UID: UTDId, Name: UTDName, Date: Date(),Text:message.text)
                                                        try await MessagesManager.deleteMessage(sol: chatTitle, id: message.id)
                                                        
                                                    }catch{
                                                        
                                                    }
                                                }
                                            })
                                        }else{
                                            messageBubble(message: message,UTDId: $UTDId, UIDShow: .constant("x"),UTDBlocks:$UTDBlocks,solName:chatTitle,delete:{
                                                
                                                Task{
                                                    do{
                                                        try await MessagesManager.deleteMessageHide(sol: chatTitle, UID: UTDId, Name: UTDName, Date: Date(),Text:message.text)
                                                        try await MessagesManager.deleteMessage(sol: chatTitle, id: message.id)
                                                        
                                                    }catch{
                                                        
                                                    }
                                                }
                                            })
                                        }
                                    }
                                    
                                }.onAppear{
                                    reader.scrollTo(MessagesManager.lastMessageId, anchor: .bottom)
                                }.onChange(of: MessagesManager.messages.count){ _ in
                                    reader.scrollTo(MessagesManager.lastMessageId, anchor: .top)
                                }
                            }.padding(.bottom)
                            
                        }
                    }
                    
                    VStack(spacing: 0){
                        Divider()
                        chatTextField(dayString: .constant(dayString), sol: $chatTitle, UTDId: $UTDId,UTDName:$UTDName).environmentObject(MessagesManager)
                    }.background(Material.ultraThickMaterial)

                }
                
            }.task{
                do{
                    try await MessagesManager.getMessages(sol: chatTitle)
                }catch{
                    
                }
            }.toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "arrow.left").foregroundColor(color.dark).fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                   messagesPieceTopArea(url: solidImage, title: chatTitle)
                }

                
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarBackButtonHidden()
        }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
/*

 */
struct messagesPieceTopArea: View {
    var url:String
    var title:String
    var body: some View {
        HStack(alignment: .center,spacing: 10){
           
            groupPP(url: url, onlySize: 38)
            VStack(alignment: .leading,spacing: 2){
                Text("\(title) Addiction").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.dark)
                Text("Chat Channel").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.dark).opacity(0.45)
            }.fontWeight(.semibold)
            Spacer()
        }
    }
}
///grup resmi alınacak firebaseden
struct messages_Previews: PreviewProvider {
    static var previews: some View {
        messages(chatTitle: .constant("Instagram"), dayString: .constant(1), solidImage: .constant("*test_image*"),UTDId: .constant("1234"), UTDName: .constant("1234"), UTDBlocks: .constant([]))
    }
}

struct groupPP: View {
    var url:String
    var onlySize:CGFloat
    var body: some View {
        ZStack{
            AsyncImage(url: URL(string: url)){ image in
                image.resizable().scaledToFill().frame(width:onlySize,height: onlySize).cornerRadius(onlySize/2).shadow(radius: 2)
            }placeholder: {
                Circle().fill(.white).frame(width: onlySize,height: onlySize).shadow(radius: 2).overlay{
                    ProgressView().frame(width: onlySize,height: onlySize)
                }
            }

        }
    }
}

struct chatTextField: View {
    @EnvironmentObject var messagesManager:messagesManager
    @State private var onlyMessage:String = ""
    @Binding var dayString:Int
    @Binding var sol:String
    @Binding var UTDId:String
    @Binding var UTDName:String
    var body: some View {
        ZStack{
            HStack{
                customTextField(placeholder: Text("write something..."), text: $onlyMessage)
                
                Button(action: {
                    messagesManager.sendMessage(text: onlyMessage,dayString: dayString, sol: sol,UTDId: UTDId,UTDName: UTDName)
                    onlyMessage = ""
                }){
                    Image(systemName: "paperplane.fill")
                }.foregroundColor(color.white).padding(8).background(color.main).cornerRadius(90)
            }.padding(.horizontal).padding()
        }
    }
}

struct customTextField:View{
    var placeholder:Text
    @Binding var text:String
    var editingChanged:(Bool) -> () = {_ in}
    var commit:() -> () = {}
    
    var body: some View{
        ZStack(alignment: .leading){
            if text.isEmpty{
                placeholder.opacity(0.3).font(.custom(CFont.AM, size: Size.sizeMedium)).padding(.leading,10)
            }
            TextField("",text:$text,onEditingChanged:editingChanged,onCommit:commit).padding(.leading,10)
        }.padding(.vertical,8).background(color.white).cornerRadius(10)
    }
    
}

