import Foundation
import FirebaseAuth

enum AuthProviderOption:String{
    case google = "google.com"
    case apple = "apple.com"
}
struct AuthDataResultModel{
    let uid:String
    let nick:String?
    let email:String?
    let photoUrl:String?
    
    
    init(user:User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.nick = user.displayName
    }

}

final class AuthenticationManager{
    static let shared = AuthenticationManager()
    private init(){}
    
    
    func getAuthenticatedUser() throws ->AuthDataResultModel{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user:user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
          guard let providerData = Auth.auth().currentUser?.providerData else {
              throw URLError(.badServerResponse)
          }
          
          var providers: [AuthProviderOption] = []
          for provider in providerData {
              if let option = AuthProviderOption(rawValue: provider.providerID) {
                  providers.append(option)
              } else {
                  assertionFailure("Provider option not found: \(provider.providerID)")
              }
          }
          print(providers)
          return providers
      }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    func delete() async throws {
            guard let user = Auth.auth().currentUser else {
                throw URLError(.badURL)
            }
            
            try await user.delete()
        }
          
}





extension AuthenticationManager {
    
    @discardableResult
    func SignInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await SignIn(credential: credential)
    }
    
    @discardableResult
    func SignInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await SignIn(credential: credential)
    }
    
    func SignIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

extension AuthenticationManager {
    
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
}
