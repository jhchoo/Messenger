//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by jae hwan choo on 2021/01/25.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private var hasFetched = false

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tabelView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLable: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(noResultsLable)
        view.addSubview(tabelView)
        setupTableview()

        searchBar.delegate = self
        view.backgroundColor = .white

        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabelView.frame = view.bounds
        noResultsLable.frame = CGRect(x: view.width/4,
                                      y: (view.height - 200) / 2,
                                      width: view.width/2,
                                      height: 200)
    }
    
    private func setupTableview() {
        tabelView.delegate = self
        tabelView.dataSource = self
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, text.replacingOccurrences(of: " ", with: "").count > 0 else {
            return
        }
        
        results.removeAll()

        spinner.show(in: view)

        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check 파이어베이스 유저
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollention):
                    self?.hasFetched = true
                    self?.users = usersCollention
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("error = \(error)")
                }
            }
        }
        
    }
    
    func filterUsers(with term: String) {
        // updatew ui
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultsLable.isHidden = false
            self.tabelView.isHidden = true
        }
        else {
            self.noResultsLable.isHidden = true
            self.tabelView.isHidden = false
            self.tabelView.reloadData()
        }
    }
    
}


extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // start conversation
    }
    
}
