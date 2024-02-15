import Firebase
import FirebaseFirestore
import Alamofire
import SwiftUI
import RevenueCat
import RevenueCatUI

struct splashRoot: View {

    @State private var start:Bool = false
    @StateObject var SolidManager = solidManager()
    @StateObject var network = NetworkManager()
    @State var OPEN:Bool = false
    @State var failure:Bool = false
    @State var x:Bool = false
    @State private var showInLogPage:Bool = false
    
    @State var userInput: String = NSLocalizedString("EULA", comment: "EULA Text")
    
    var body: some View {
        ZStack{
           
            splashView(failure: $failure)
            
            if (!showInLogPage && OPEN){
                
                mainGPage(showInLogPage: $showInLogPage, ST: .constant(.house))
            }
            
            
        }
        .onChange(of: OPEN){ newValue in
            if(newValue){
                let autherUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                
                self.showInLogPage = autherUser == nil

            }
        }
        .task{
            if network.isConnected {
                openQuery()
            }else{
                failure = true
            }

            
            Task {
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    self.start = customerInfo.entitlements["pro"]?.isActive != true
                    
                } catch {
                    print("Hata: \(error)")
                }
            }
        }
        .fullScreenCover(isPresented: $start){
            paywallPreview0(start: $start)
        }
        .fullScreenCover(isPresented: $showInLogPage){
            NavigationStack{
                inLogPage(showInLogPage:$showInLogPage)
            }
        }
    }
    
    func openQuery(){
        let path = Firestore.firestore().collection("ROOT").document("VALUE")
        
        path.getDocument { document, error in
            if let document = document, document.exists {
                if let isOpen = document.data()?["OPEN"] as? Bool, isOpen {
                    withAnimation{
                        OPEN = true
                    }
                } else {
                    OPEN = false
                }
            } else {
                OPEN = false
            }
        }
    }
}



#Preview {
    splashRoot()
}
class NetworkManager: ObservableObject {
    let reachabilityManager = NetworkReachabilityManager()
    @Published var isConnected: Bool = false

    init() {
        self.startNetworkReachabilityObserver()
    }

    func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening { status in
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self.isConnected = true
            
            case .notReachable, .unknown:
                self.isConnected = false
            }
        }
    }
}
struct splashView: View {
    @Binding var failure:Bool
    var body: some View {
        VStack{
            
            ILPText(text: "LifeFul", color: color.white, family: "AvenirNext-Heavy", size: Size.sizeUltraLarge,weight:.bold)
            
            
            if failure {
                ILPText(text: "failed to connect", color: color.mainEraser, family: CFont.ABO, size: Size.sizeLarge, weight: .bold)
            }
            
        }.frame(maxWidth: .infinity,maxHeight: .infinity).background(color.main.gradient)
    }
}
