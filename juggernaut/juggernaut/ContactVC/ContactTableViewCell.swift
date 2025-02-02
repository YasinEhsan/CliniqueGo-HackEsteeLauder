//
//  ContactTableViewCell.swift
//  juggernaut
//
//  Created by Helal Chowdhury on 10/11/19.
//  Copyright © 2019 Helal. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    
   let images = ["profile", "profile1", "profile2", "profile3", "profile4"]
    let points = ["32", "25", "86", "93", "10", "65"]
    
    func setContact(_ contact: Contact, _ indexPath: Int) {
        nameLabel.text = contact.firstName + " " + contact.familyName
        profileView.image = UIImage(named: images[indexPath%5])
        pointsLabel.text = points[indexPath%6]
        
    }

}
