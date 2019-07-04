//
//  UserCell.swift
//  WebimTest
//
//  Created by Alena on 03/07/2019.
//  Copyright © 2019 Alena. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    @IBOutlet private var lastNameLabel: UILabel!
    @IBOutlet private var firstNameLabel: UILabel!
    @IBOutlet private var avatar: UIImageView!
    
    func setUserInfo(_ info: [String: AnyObject]) {
        lastNameLabel.text = info["last_name"] as? String ?? ""
        firstNameLabel.text = info["first_name"] as? String ?? ""
        guard let photoRef = info["photo_100"] as? String,
            let photoURL = URL(string: photoRef) else { return }
        let imageService = ImageService()
        imageService.downloadImage(from: photoURL) { data in
            DispatchQueue.main.async {
                self.avatar.image = UIImage(data: data)
            }
        }
    }
}
