//
//  AppDelegate.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/25.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        // 구글 로그인
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        // 페이스북
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    // 페이스북 에서 추가.
    // 외부 open url
    func application(_ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 페이스북
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        // 구글 로그인
        GIDSignIn.sharedInstance().handle(url)
        
        return true
    }
        
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension AppDelegate: GIDSignInDelegate {
    // 구글 로그인
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google \(error)")
            }
            return
        }
        
        guard let authentication = user.authentication else {
            print("구글 유저가 없다.")
            return
        }
        
        guard  let email = user.profile.email,
               let firstName = user.profile.givenName,
               let lastName = user.profile.familyName else {
            return
        }
        DatabaseManager.shared.userExists(with: email, provider: "Google") { (exists) in
            if !exists {
                DatabaseManager.shared.insertUser(with: ChatAppUser(provider: "Google",
                                                                    firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
            }
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { (authResult, error) in
            guard let result = authResult, error == nil else {
                print("Error")
                return
            }
            
            let user = result.user
            print("로그인 성공 usre = \(user)")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google user was disconnect")
    }
}
