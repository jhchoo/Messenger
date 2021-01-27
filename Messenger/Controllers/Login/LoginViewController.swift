//
//  LoginViewController.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/25.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()

    private let signInButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main) { [weak self] (notification) in
            // 로그인 성공하면  dismiss 한다.
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Register",
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookButton.delegate = self
        
        // 자식 뷰 추가.
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookButton)
        scrollView.addSubview(signInButton)
    }
    
    deinit {
        print("loginObserver deinit")
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        
        emailField.frame = CGRect(x: 30,
                                 y: imageView.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                 y: passwordField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
        facebookButton.frame = CGRect(x: 30,
                                 y: loginButton.bottom + 20,
                                 width: scrollView.width - 60,
                                 height: 52)
        signInButton.frame = CGRect(x: 30,
                                 y: facebookButton.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    }
    
    @objc private func loginButtonTapped() {

        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard  let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty
               , password.count >= 6 else {
            alertUserLoginError( )
            return
        }
        
        // 파이어베이스 로그인
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let result = authResult, error == nil else {
                print("Error")
                return
            }
            
            let user = result.user
            print("usre = \(user)")
            // 성공하면  dismiss 한다.
            
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(message: String = "Please enter all information to log in") {
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    

    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("페이스북 로그인 실패")
            return
        }
        
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":"id,email,first_name,last_name,name"],
                                                         tokenString: token,
                                                         version: nil, httpMethod: .get)
        facebookRequest.start { (connection, result, error) in
            guard let result = result as? [String: Any], error == nil else {
                print("ERROR")
                return
            }
            
            print("\(result)")
            
            let email = result["email"] as? String ?? ""
            
            DatabaseManager.shared.userExists(with: email, provider: "facebook") { (exists) in
                guard !exists else {
                    return
                }
                DatabaseManager.shared.insertUser(with: ChatAppUser(provider: "facebook",
                                                                    firstName: result["first_name"] as? String ?? "",
                                                                    lastName: result["last_name"] as? String ?? "",
                                                                    emailAddress: email))
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (authDataResult, error) in
                guard let result = authDataResult, error == nil else {
                    if let error = error {
                        print("Error 페이스북 로그인 \(error)")
                    }
                    return
                }
                
                let user = result.user
                print("usre = \(user)")

                // 성공하면  dismiss 한다.
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
        
}
