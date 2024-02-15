//
//  twentyOneDayApp.swift
//  twentyOneDay
//
//  Created by Burak on 8.08.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import RevenueCat
import RevenueCatUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
      
  }
}

@main
struct twentyOneDayApp: App {

    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        Purchases.configure(with: .init(withAPIKey: "API-KEY")
            .with(usesStoreKit2IfAvailable:true))
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("N-Color01"))
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color("N-Color02"))
    }
    
    var body: some Scene {
        WindowGroup {
            splashRoot()
        }
    }
}






