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
    
    static func safeEmail(emailAdress: String, provider: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        safeEmail = "\(provider)-\(safeEmail)"
        return safeEmail
    }
    
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
        ]) { [weak self] (error, reference) in
            guard error == nil else {
                print("error")
                completion(false)
                return
            }
            
            // 유저리스트 추가.
            self?.database.child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                if var usersCollection = dataSnapshot.value as? [[String:String]] {
                    // append to user dictionnary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self?.database.child("users").setValue(usersCollection) { (error, reference) in
                        guard error == nil else {
                            print("error")
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                } else {
                    // create that array
                    let newCollection: [[String:String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self?.database.child("users").setValue(newCollection) { (error, reference) in
                        guard error == nil else {
                            print("error")
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            })
            
            completion(true)
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>)-> Void) {
        database.child("users").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let value = dataSnapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseEror.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseEror: Error {
        case failedToFetch
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
