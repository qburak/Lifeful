
import SwiftUI

struct rootView: View {
    
    @StateObject var SolidManager = solidManager()
    
    @State private var showInLogPage:Bool = false
    
    @Binding var ST:Tab
    var body: some View {
        ZStack{
            if !showInLogPage{
                   mainGPage(showInLogPage: $showInLogPage, ST: .constant(ST))
            }
            
        }.onAppear{
            let autherUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            
            self.showInLogPage = autherUser == nil

        }.fullScreenCover(isPresented: $showInLogPage){
            NavigationStack{
                inLogPage(showInLogPage:$showInLogPage).environment(\.colorScheme, .light).environment(\.colorScheme, .light)
            }
        }
    }
}

struct rootView_Previews: PreviewProvider {
    static var previews: some View {
        rootView(ST: .constant(.house))
    }
}
