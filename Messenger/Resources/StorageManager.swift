//
//  StorageManager.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/28.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()

    /*
        /images/afraz9-gmail-com_profile_picture.png
        */
    
    public typealias UploadPicktureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase
    public func uploadProfilePickture(with data: Data, fileName: String, completion: @escaping UploadPicktureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] (storageMetadata, error) in
            guard let metadata = storageMetadata else {
                if let error = error {
                    completion(.failure(error))
                }
                print("failed to upload data to firebase for picture")
                return
            }
            
            print("metadata = \(String(describing: metadata.contentType))")
            
            self?.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("error")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url = \(urlString)")
                completion(.success(urlString ))
            }
            
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
}
