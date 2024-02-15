//
//  globalPage.swift
//  twentyOneDay
//
//  Created by Burak on 28.09.2023.
//

import SwiftUI

struct globalPage: View {
    @State var areaNum:CGFloat = 0
    @State var title:String = ""
    @State var description:String = ""
    @State var errorsValue:Bool = false
    @State var alertOnlyValue:Bool = false
    @State var alertOnlySucValue:Bool = false
    @StateObject var SolidManager = solidManager()
    @State var errorPoint:Bool = false
    @State var loading:Bool = false
    @State private var userInput: String = ""
      private var textFieldDisplay: String {
          return userInput + "xxx"
      }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        NavigationStack{
            ZStack{
                
                List{
                    Section(header: HStack{
                        Spacer()
                        Text("Which Addiction would you like to see in our app ?").multilineTextAlignment(.center)
                        Spacer()
                    }){
                        
                    }.padding(.bottom)
                    
                    Section(header: Text("The Name of Addiction")){
                        customGlobalTF(placeholder: Text(""), maxLenght: 30, text: $title).onChange(of: title){ newValue in
                            
                            SolidManager.controlGP(solidName: newValue){ value in
                                if value{
                                    errorsValue = true
                                }else{
                                    errorsValue = false
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("")){
                        Button(action: {
                            if(errorsValue){
                                
                                alertOnlyValue = true
                                
                            }else{
                                loading = true
                                Task{
                                    do{
                                        try await SolidManager.userRequest(solName: title)
                                        
                                        alertOnlySucValue = true
                                        loading = false
                                    }catch{
                                        loading = false
                                    }
                                }
                                
                            }
                        }){
                            if(!loading){
                                Text("Send")
                            }else{
                                ProgressView()
                            }
                        }.font(.custom("Avenir-Roman", size: Size.sizeLarge)).frame(maxWidth: .infinity).foregroundStyle(color.main).disabled(loading || title.isEmpty)
                    }
                }
                alertGP(alert: $alertOnlyValue, title: "Error", message: "This Addiction already exists", action: {
                })
                alertGP(alert: $alertOnlySucValue, title: "Info", message: "Thank you\nWe will look into it as soon as possible...",action: {
                    presentationMode.wrappedValue.dismiss()

                })
            }.toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()

                    }){
                        Image(systemName: "chevron.left").fontWeight(.semibold).foregroundStyle(color.main)
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Suggestion").font(.custom(CFont.ABO, size: Size.sizeLarge)).foregroundStyle(color.dark).fontWeight(.semibold)
                }
                
             
                
            }
        }.navigationBarBackButtonHidden()
        
            
        
    }

}

struct globalPage_Previews: PreviewProvider {
    static var previews: some View {
        globalPage()
    }
}


struct customGlobalTF:View{
    var placeholder:Text
    var maxLenght:Int
    @Binding var text:String
    var editingChanged:(Bool) -> () = {_ in}
    var commit:() -> () = {}
    
    var body: some View{
        VStack(spacing: 5) {
            ZStack(alignment: .leading){
                if text.isEmpty{
                    HStack(spacing: 0){
                        placeholder.opacity(0.3).font(.custom("Avenir-Roman", size: Size.sizeLarge))
                    }
                }else{
                    HStack(spacing: 0){
                        Text("\(text) Addiction").font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundColor(color.dark)
                    }
                }
                HStack{
                    Spacer()
                    Text("\(maxLenght - text.count)").foregroundColor(color.dark.opacity(0.4))
                }
                HStack {
                    TextField("",text:$text,axis: .vertical).font(.custom("Avenir-Roman", size: Size.sizeLarge)).foregroundColor(Color.black.opacity(0)).onChange(of: text){text in
                        
                        if text.count > maxLenght {
                            self.text = String(text.prefix(maxLenght))
                        }
                    }
                }.lineLimit(2)
            }
        }
    }
        
}
 

struct alertGP: View {
    @Binding var alert:Bool
    var title:String
    var message:String
    var action:() -> Void

    var body: some View {
        ZStack{}
            .alert(isPresented: $alert){
                Alert(title: Text(title),message: Text(message),dismissButton: .default(Text("Ok."),action: {
                    alert = false
                    action()
                }))
            }
    }
}
