//
//  ProfileViewController.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/25.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseStorage

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = createTableHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func createTableHeader() -> UIView {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let provider = UserDefaults.standard.value(forKey: "provider") as? String else {
            return UIView()
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email, provider: provider)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName

        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (view.width - 150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2.0
        
        headerView.addSubview(imageView)

        StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
                print("a")
            case .failure(let error):
                print("error downloadURL \(error)")
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                print("fail download facebook image")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
            
            
        }.resume()
        
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        alertCreatUser()
        
    }
    
    
    func alertCreatUser() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
            
            do {
                // 파이어베이스 로그아웃
                try FirebaseAuth.Auth.auth().signOut()
                
                // 페이스북 로그아웃 시킴
                FBSDKLoginKit.LoginManager().logOut() // this is an instance function
                
                // 구글 로그아웃
                GIDSignIn.sharedInstance()?.signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true)
            } catch {
                print("Failed logout")
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}
