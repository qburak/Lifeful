//
//  filterPage.swift
//  twentyOneDay
//
//  Created by Burak on 25.09.2023.
//

import SwiftUI

struct filterPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    @Binding var stageNumber:Int
    @Binding var all:Bool
    @Binding var emoji:String
    var body: some View {
        NavigationStack{
            ZStack(alignment: .center){
                List{
                    Section(header:Text("stage").textCase(.lowercase).font(.custom(CFont.ABO, size: Size.sizeMedium + 2))){
                        customStageMenu(stageNumber: $stageNumber)
                    }
                    Section(header:Text("Addiction").textCase(.lowercase).font(.custom(CFont.ABO, size: Size.sizeMedium + 2))){
                        customFMenu(isItAll: $all)
                    }
                    Section(header:Text("Mood").textCase(.lowercase).font(.custom(CFont.ABO, size: Size.sizeMedium + 2))){
                        customEmojiMenu(onlyEmoji: $emoji)
                    }
                }.listStyle(.sidebar)
            }.padding(.vertical,0).toolbar{
                ToolbarItem(placement: .principal){
                    Text("Entry Filtering")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .foregroundStyle(color.dark)
                        .fontWeight(.semibold)
                        .padding(25)
                }
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left").foregroundStyle(color.dark).fontWeight(.semibold)
                    }
                  
                }
            }.navigationBarBackButtonHidden()
        }
        
    }
}

struct customEmoji:View{
    @Binding var sSelection:Int
    @Binding var sValue:CGFloat
    @Binding var emojiValue:String
    var questionsEmoji:[String] = ["😁","😃","🙂","🙁","😔","😫"]
    var body: some View{
        
            VStack(spacing: 40) {
                ForEach(0...1,id:\.self){indexF in
                    HStack(spacing: 40) {
                        ForEach(0...2,id:\.self){index in
                            
                            Button(action: {
                                emojiValue = questionsEmoji[index == 1 ? index + 3:index]
                                withAnimation{
                                    sSelection += 1
                                }
                            }){
                                Text(questionsEmoji[indexF == 1 ? index + 3 : index]).font(.system(size: 40))
                            }
                        }
                    }
                    
                    
                }
                    
                
            }.frame(maxWidth: .infinity)
    }
}

struct customStageMenu:View{
    @Binding var stageNumber:Int
    var body: some View{
        Picker("Time Unit", selection: $stageNumber) {
            ForEach(1...11,id:\.self){value in
                Text("\(value)").tag(value)
            }
        }.pickerStyle(.segmented).padding(.vertical,12)
    }
}



struct customFMenu: View {
    @Binding var isItAll:Bool
    var body: some View {
        Picker("Time Unit", selection: $isItAll) {
            Text("relevant").tag(false)
            Text("all").tag(true)

            
        }.pickerStyle(.segmented).padding(.vertical,12)
    }
}
struct customEmojiMenu: View {
    @State var Emojies:[String] = ["-","😁","😃","🙂","🙁","😔","😫"]
    @Binding var onlyEmoji:String
    var body: some View {
        Picker("Emoji",selection: $onlyEmoji){
            ForEach(0...5,id:\.self){ index in
                Text("\(Emojies[index])").tag(Emojies[index])
            }
        }.pickerStyle(.segmented)
    }
}
struct filterPage_Previews: PreviewProvider {
    static var previews: some View {
        filterPage(stageNumber: .constant(0), all: .constant(false),emoji: .constant("😆"))
    }
}
