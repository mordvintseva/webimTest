//
//  InfoController.swift
//  WebimTest
//
//  Created by Alena on 02/07/2019.
//  Copyright © 2019 Alena. All rights reserved.
//

import Foundation
import UIKit
import VK_ios_sdk

class InfoViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    private let alert = UIAlertController(title: "Can not load friends list", message: "Try again later", preferredStyle: .alert)
    private var friends = [[String: AnyObject]]()
    private var token: VKAccessToken! {
        didSet {
            getProfileInfoRequest()
            getFriendsRequest()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        self.friendsTableView.register(nib, forCellReuseIdentifier: "UserCell")
        self.friendsTableView.dataSource = self
        self.friendsTableView.tableFooterView = UITableViewHeaderFooterView()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(backButtonPressed))
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        VKSdk.forceLogout()
        self.navigationController?.popViewController(animated: true)
    }

    func set(_ token: VKAccessToken) {
        self.token = token
    }
    
    func getProfileInfoRequest() {
        let profileInfoRequest = VKRequest(method: "account.getProfileInfo", parameters: [:])
        profileInfoRequest?.execute(resultBlock: { response in
            guard let response = response?.json as? [String: AnyObject] else { return }
            let lastName = response["last_name"] as? String ?? ""
            let firstName = response["first_name"] as? String ?? ""
            self.nameLabel.text = "\(lastName) \(firstName)"
        }, errorBlock: { error in
            self.alert.present(self, animated: true, completion: nil)
        })
    }

    func getFriendsRequest() {
        let params = ["order": "random", "count": "5", "fields": "nickname, photo_100", "name_case": "nom"]
        let friendsRequest = VKRequest(method:  "friends.get", parameters: params)
        friendsRequest?.execute(resultBlock: { response in
            guard let response = response else { return }
            self.getFriendsList(response) }, errorBlock: { error in
                self.alert.present(self, animated: true, completion: nil) }
        )
    }

    func getFriendsList(_ response: VKResponse<VKApiObject>) {
        guard let dict = response.json as? [String: AnyObject],
            let items = dict["items"] as? [[String: AnyObject]] else { return }
        items.forEach { self.friends.append($0) }
        DispatchQueue.main.async {
            self.friendsTableView.reloadData()
        }
    }
}

extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            fatalError("Can not display cell")
        }
        cell.setUserInfo(friends[indexPath.row])
        return cell
    }
}
