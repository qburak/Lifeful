import SwiftUI

enum Tab:String, CaseIterable{
    case house
    case binoculars
    case person
}

struct customTabBar: View {
    @Binding var selectedTab:Tab
    @Binding var po1:Bool
    
    private var fillImage:String {
        selectedTab.rawValue + ".fill"
    }
    var body: some View {
        VStack{
            Spacer()
            
            VStack {
                Divider()
                Spacer()
                HStack{
                    
                    ForEach(Tab.allCases, id: \.rawValue){ tab in
                        Spacer()
                        Image(systemName: selectedTab == tab ? fillImage : tab.rawValue).scaleEffect(selectedTab == tab ? 1.25 : 1.0).foregroundColor(selectedTab == tab ? color.main : color.dark).font(.system(size: 22)).onTapGesture {
                            withAnimation(.easeIn(duration: 0)){
                                selectedTab = tab
                            }
                        }
                            
                        
                        Spacer()
                    }
                }.popover(isPresented: $po1,attachmentAnchor: .point(.bottomLeading)){
                    VStack{
                        Text("your addiction is here")
                    }.foregroundStyle(color.dark)
                    .padding(.horizontal).presentationCompactAdaptation(.popover)
                }.onChange(of:po1){
                    if !po1{
                        UserDefaults.standard.set(true, forKey: "CTBHelper")
                    }
                }
            }.frame(width: nil,height: 60).background(Color("N-Color00"))
               
            
        }
    }
}

struct customTabBar_Previews: PreviewProvider {
    static var previews: some View {
        customTabBar(selectedTab: .constant(.house),po1: .constant(true))
    }
}
