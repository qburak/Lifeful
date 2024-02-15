
import SwiftUI
import RevenueCat
import RevenueCatUI

struct CustomPayWallView: View {

    @StateObject var viewModel = PaywallViewModel()

    @State var selection:Int = 0
    @Binding var start:Bool

    var body: some View {
        if let offerings = viewModel.currentOffering {
            
            NavigationStack{
                GeometryReader{ geo in
                    ZStack{
                        
                        VStack(spacing: 0){
                            
                            
                            
                            VStack{
                                Image("IAPImage").resizable().scaledToFit()
                                    .mask(
                                        LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)
                                    )
                                
                                
                                
                                VStack(alignment:.leading,spacing:10){
                                    IAPTextFirst(title: "other features", image: "circle.dotted").fontWeight(.heavy).padding(.bottom)
                                    IAPTextFirst(title: "chat with people with the same addiction", image: "checkmark")
                                    IAPTextFirst(title: "daily control and emotion analysis", image: "checkmark")
                                    IAPTextFirst(title: "more than 20 addiction solidarities", image: "checkmark")
                                }.frame(height: geo.size.height / 1.8).padding(.horizontal,12)
                                    
                            
                                
                            }.ignoresSafeArea()
                            
                        }
                        
                        
                    }
                    
                }.paywallFooter(offering: offerings, purchaseCompleted: { CustomerInfo in
                    start = false
                },restoreCompleted:  { customerInfo in
                    start = false
                }).navigationBarBackButtonHidden()
                
                
            }
        } else {
            VStack{
                ProgressView()
                Text("loading offers...")
            }
        }
        
        
    }
}
#Preview {
    CustomPayWallView(start:.constant(false))
}
struct IAPTitle: View {
    var title:String
    var subTitle:String
    
    var body: some View {
        VStack(spacing:30){

            VStack{
                
                Text(title).font(.custom(CFont.ABO, size: Size.sizeUltraLarge))
                Text(subTitle).font(.custom(CFont.ABO, size: Size.sizeLarge)).multilineTextAlignment(.center)
            }.fontWeight(.regular)
                .padding(.horizontal,12)
        }.foregroundStyle(color.dark)
    }
}
struct paywallPreview1: View {
    @Binding var start:Bool
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    Image("preview1").resizable().scaledToFill()
                        .blur(radius: 0, opaque: true).frame(width: geo.size.width,height: geo.size.height)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            ).mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topLeading
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topTrailing
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.main]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.main]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                        .overlay{
                            VStack{
                                
                                Rectangle().fill(.clear).frame(width: geo.size.width,height: geo.size.height / 5).blur(radius: 2).overlay{
                                    IAPTitle(title: "entries", subTitle: "share and read about\n addiction recovery processes")
                                }
                          
                                Spacer()
                                Text("• entries").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.mainCounter)
                                NavigationLink(destination: paywallPreview2(start:$start)){
                                    CustomPaywallViewButton(width: geo.size.width / 2, height: geo.size.height / 12, text: "Continue", Bcolor: color.dark)
                                }
                            }
                        }.frame(width: geo.size.width)
                        
                    
                    
                    
                }.navigationBarBackButtonHidden()
            }
        }
    }
}


struct paywallPreview2: View {
    @Binding var start:Bool
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    Image("preview2").resizable().scaledToFill()
                        .blur(radius: 0, opaque: true)
                        .clipped().frame(width: geo.size.width,height: geo.size.height)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            ).mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topLeading
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topTrailing
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.main]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.main]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                        .overlay{
                            VStack{
                                
                                Rectangle().fill(.clear).frame(width: geo.size.width,height: geo.size.height / 5).blur(radius: 2).overlay{
                                    IAPTitle(title: "savings", subTitle: "realise the savings of the process\nfind out how much savings you will have in the future")
                                }
                          
                                Spacer()
                                Text("• savings").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.mainCounter)
                                NavigationLink(destination: CustomPayWallView(start: $start)){
                                    CustomPaywallViewButton(width: geo.size.width / 2, height: geo.size.height / 12, text: "Continue", Bcolor: color.dark)
                                }
                            }
                        }.frame(width: geo.size.width)
                        
                    
                    
                    
                }.navigationBarBackButtonHidden()
            }
        }
    }
}
#Preview{
    paywallPreview2(start: .constant(true))
}

struct paywallPreview0: View {
    @Binding var start:Bool
    var body: some View {
        GeometryReader{ geo in
            NavigationStack{
                ZStack{
                    Image("preview0").resizable().scaledToFill()
                        .blur(radius: 0, opaque: true).frame(height: geo.size.height)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .top
                                )
                            ).mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topLeading
                                )
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .clear]),
                                    startPoint: .center,
                                    endPoint: .topTrailing
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.main]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, color.mainCounter]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                        .overlay{
                            VStack{
                                
                                Rectangle().fill(.clear).frame(width: geo.size.width,height: geo.size.height / 5).blur(radius: 2).overlay{
                                    IAPTitle(title: "get rid of", subTitle: "we made addiction recovery easier")
                                }
                          
                                Spacer()
                                Text("• Features").font(.custom(CFont.ABO, size: Size.sizeMedium)).foregroundStyle(color.main)
                                NavigationLink(destination: paywallPreview1(start:$start)){
                                    CustomPaywallViewButton(width: geo.size.width / 2, height: geo.size.height / 12, text: "I'm ready", Bcolor: color.dark)
                                }
                            }
                        }.frame(width: geo.size.width)
                        
                    
                    
                    
                }
                .navigationBarBackButtonHidden()
            }
        }
    }
}

struct CustomPaywallViewButton: View {
    var width:CGFloat
    var height:CGFloat
    var text:String
    var Bcolor:Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .circular).stroke(lineWidth: 1).foregroundStyle(.white).overlay{
            Text(text)
                .shadow(radius: 4)
                .font(.custom(CFont.AB, size: Size.sizeLarge))
                .fontWeight(.semibold)
                .foregroundStyle(color.white)
                
            
            
        }
        .padding(.bottom,20)
        .frame(width: width,height: height)

    }
}

class PaywallViewModel: ObservableObject {
    @Published var currentOffering: Offering?

    init() {
        Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                currentOffering = offerings.current
            } catch {
                print("Hata: \(error)")
            }
        }
    }
}

struct IAPText: View {
    var title:String
    var subTitle:String
    var image:String
    var body: some View {
        VStack(spacing:15){
            Image(systemName: image).font(.system(size: Size.sizeUltraLarge - 4)).foregroundColor(color.main).shadow(color: color.mainEraser,radius: 5).fontWeight(.light)
            VStack{
                Text(title).font(.custom(CFont.ABO, size: Size.sizeUltraLarge))
                Text(subTitle).font(.custom(CFont.ABO, size: Size.sizeLarge))
            }
        }.foregroundStyle(color.dark)
    }
}
struct IAPTextFirst: View {
    var title:String
    var image:String
    @State var popover:Bool = false
    var body: some View {
        HStack(spacing:15){
          
            Image(systemName: image).font(.system(size: Size.sizeLarge )).foregroundColor(color.main).shadow(color: color.mainEraser.opacity(0.8),radius: 3).shadow(color: color.mainEraser,radius: 8)
            VStack{
                Text(title).font(.custom(CFont.ABO, size: Size.sizeLarge + 2))
            }
        }.foregroundStyle(color.dark)
            
    }
}
