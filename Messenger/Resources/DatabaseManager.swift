//
//  DataBaseManager.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/26.
// 

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// MARK: 사용자 매니저
extension DatabaseManager {
    
    public func userExists(with email: String, provider: String, complition: @escaping((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        safeEmail = "\(provider)-\(safeEmail)"
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            if snapshot.value == nil || snapshot.value as! NSObject == NSNull() {
                complition(false)
            } else {
                complition(true)
            }
        })

    }
    
    /// Insert new users to database
    public func insertUser(with user: ChatAppUser, completion: @escaping ((Bool) -> Void)  ) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ]) { (error, reference) in
            guard error == nil else {
                print("error")
                completion(false)
                return
            }
            completion(true)
        }
    }
}


struct ChatAppUser {
    let provider: String
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        safeEmail = "\(provider)-\(safeEmail)"
        return safeEmail
    }
    
    var profilePictureFileName: String {
        /*
                /images/afraz9-gmail-com_profile_picture.png
                */
        return "\(safeEmail)_profile_picture.png"
    }
}
