import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


@MainActor
final class AuthenticationViewModel: ObservableObject {
        
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.SignInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.SignInWithApple(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }

}


struct ILPText: View {
    var text:String
    var color:Color
    var family:String
    var size:CGFloat
    var weight:Font.Weight
    var body: some View {
        Text(text)
            .font(.custom(family, size: size))
            .foregroundStyle(color)
            .fontWeight(weight)
            
    }
}

struct inLogPage: View {
    
    @Binding var showInLogPage:Bool

    @State var UTDContract:Bool = false
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        GeometryReader { g in
            
            VStack{
                
                Spacer()
                
                ILPText(text: "LifeFul", color: color.white, family: "AvenirNext-Heavy", size: Size.sizeUltraLarge,weight:.bold )
                
                ILPText(text: "step by step from addiction to freedom", color: color.mainEraser, family: CFont.ABO, size: Size.sizeLarge, weight: .bold)
                
                Spacer()
                
                VStack(spacing: 20){
                    
                    VStack(spacing:15) {
                        color.mainCounter.frame(width: 45,height: 0.8)
                        
                        ILPText(text: "take the first step", color: color.mainCounter, family: CFont.ABO, size: Size.sizeLarge, weight: .bold)
                        
                        
                        Image(systemName: "arrow.down.circle.dotted").font(.system(size: Size.sizeLarge + 10))
                            .fontWeight(.light)
                        
                    }
                    .foregroundStyle(color.mainCounter)
                    .padding(.bottom,40)
                    .opacity(0.75)
                    
                    
                    customLogInButtons(image: "apple.logo", text: "Sign in with Apple", isSystemValue: true).onTapGesture {
                        Task{
                            do{
                                try await viewModel.signInApple()
                                showInLogPage = false
                                
                            }catch{
                                print(error)
                            }
                        }
                    }
                    
                    customLogInButtons(image: "googleLogo", text: "Sign in with Google", isSystemValue: false).onTapGesture {
                        Task{
                            do{
                                try await viewModel.signInGoogle()
                                showInLogPage = false
                            }catch{
                                print(error)
                            }
                        }
                    }
                    
                    
                    
                }.padding(.bottom,40).padding(.horizontal,50)
                
                
            }.background(color.main.gradient)
            
            
        }
        
    }
}




struct inLogPage_Previews: PreviewProvider {
    static var previews: some View {
        
        inLogPage(showInLogPage:.constant(false))
             
        
    }
}

struct customLogInButtons:View{
    var image:String
    var text:String
    var isSystemValue:Bool
    var body: some View{
        HStack(spacing:6){
            if isSystemValue{
                Image(systemName: image)
            }else{
                Image(image).resizable().frame(width: 15,height: 15).colorMultiply(.blue)
            }
            
            Spacer()

            Text(text).font(.custom(CFont.ABO, size: Size.sizeLarge)).fontWeight(.medium)
            Spacer()
            
        }.padding().frame(maxWidth: .infinity).background(.regularMaterial).cornerRadius(15)
    }
}

struct contractPageF: View {
    @StateObject var solEntryViewModel = SolEntryViewModel()
    @State var userInput: String = NSLocalizedString("EULA", comment: "EULA Text")
    
    @Binding var UTDContract:Bool
    @State var loading:Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    TextEditor(text: $userInput)
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .padding(.horizontal,20)
                        .fontWeight(.light)
                }
            }.toolbar{
                
                ToolbarItem(placement: .bottomBar){
                   
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "contract")
                            UTDContract = false
                        }){
                            ZStack{
                                
                                Text("Accept EULA")
                                
                            }.padding(20)
                            
                                
                            
                            
                        }.disabled(loading)
                        .foregroundStyle(loading ? .gray : color.main)
                        .font(.custom(CFont.ABO, size: Size.sizeLarge))
                        .fontWeight(.bold)
                        .cornerRadius(15)
                        
                       
                    
                }
                ToolbarItem(placement: .principal){
                    Text("End User Licence Agreement (EULA)")
                        .font(.custom(CFont.ABO, size: Size.sizeLarge + 2.5))
                        .foregroundStyle(color.dark)
                        .fontWeight(.bold)
                    

                }
            }
        }
    }
}
