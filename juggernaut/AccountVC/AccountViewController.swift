//
//  AccountViewController.swift
//  juggernaut
//
//  Created by Helal Chowdhury on 10/11/19.
//  Copyright © 2019 Helal. All rights reserved.
//

import UIKit
import EventKit
import FirebaseDatabase


class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scoreView: UIImageView!
    @IBOutlet weak var itemListTableView: UITableView!
    
    var items = ["item1", "item4", "item3"]
    var orderItems = ["Moisture Surge", "Fresh Pressed", "Makeup Remover",]
    var selectedItems = [String]()
    let map = ["Moisture Surge": "item2","Fresh Pressed": "item1", "Makeup Remover": "item4"]
    
    
    let ref = Database.database().reference()
    var databaseHandle:DatabaseHandle?
    var postData = [String]()
    var display: String = ""
    
           
    override func viewDidLoad() {
        super.viewDidLoad()
        itemListTableView.dataSource = self
        itemListTableView.delegate = self
        scoreView.image = UIImage(named: "startingPoints")
        
        //OBSERVER
        databaseHandle = ref.child("OrderHistory").observe(.childAdded) { (snapshot) in
            
            let dict = snapshot.value as? [String:Any]
            let orderItem = dict?["Order Item"] as? String
            let orderPoints = dict?["Order Points"] as? String
            
            self.selectedItems.append(orderItem ?? "")
            self.selectedItems = Array(self.selectedItems.reversed())
            
            self.itemListTableView.reloadData()

        }
    }
    
    
    @IBAction func buttonClicked(_ sender: Any) {
//        items = ["item2","item1", "item4", "item3"]
        
        if let appURL = URL(string: "shoebox://"){
            let canOpen = UIApplication.shared.canOpenURL(appURL)
            print("\(canOpen)")
            
            let appName = "Wallet"
            let appScheme = "\(appName)://"
            let appSchemeURL = URL(string: appScheme)
            
            if UIApplication.shared.canOpenURL(appSchemeURL! as URL) {
                UIApplication.shared.open(appSchemeURL!, options: [:], completionHandler: nil)
            }
            else {
                let alert = UIAlertController(title: "\(appName) Error..", message: "The app named \(appName) was not found", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scoreView.image = UIImage(named: "endingPoints")
//            self.itemListTableView.beginUpdates()
//            self.itemListTableView.insertRows(at: [indexPath], with: .automatic)
//            self.itemListTableView.endUpdates()
        }
        view.endEditing(true)
        
        let eventStore:EKEventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event) {(granted, error) in
                if (granted) && (error) == nil
                {
                    print("granted \(granted)")
                    print("error \(error)")
                    
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    event.title = "You Recycled A Product Today"
                    event.startDate = Date()
                    event.endDate = Date()
                    event.notes = ""
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError{
                        print("error : \(error)")
                    }
                    print("Save Event")
                } else{
                    print("error : \(error)")
                }
                
            }

       
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 3,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemID") as! ItemTableViewCell
        cell.itemView.image = UIImage(named: map[selectedItems[indexPath.row]] ?? "item3")
        return cell
    }
}

extension UIView {
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}




