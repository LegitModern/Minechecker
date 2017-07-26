//
//  MinecraftAccount.swift
//  Minehistory
//
//  Created by Ryan Donaldson on 7/22/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import Alamofire

class MinecraftAccount {
    
    var playerName: String?
    var playerUUID: String?
    var playerUUIDFormatted: String?
    var names = [String]()
    var dateChanged = [String]()
    
    let dateFormatter = DateFormatter()
    
    init(playerName: String) {
        self.playerName = playerName
    }
    
    func fetchItems(_ view: UIView, viewController: UIViewController, success: @escaping () -> ()) {
        Alamofire.request("https://mcapi.de/api/user/\(self.playerName!)").responseJSON { response in
            if response.result.error != nil {
                //TODO: Display alert to user? Not too sure how this will work until I implement.
                print("Error occured while performing HTTP request: \(response.result.error!.localizedDescription)")
                self.createAlertController(viewController)
                self.hideLoadingHUD(view)
            } else {
                if response.result.value != nil {
                    self.names.removeAll(keepingCapacity: true)
                    self.dateChanged.removeAll(keepingCapacity: true)
                    let json = JSON(response.result.value!)
                    print(response.data!)
                    print(json)
                    
                    if let result = json["result"]["status"].string {
                        if result == "Error" {
                            self.noUsernameAlert(viewController)
                            self.hideLoadingHUD(view)
                        }
                    }
                    if let uuid = json["uuid"].string {
                        self.playerUUID = uuid
                        var uuidFormatting = uuid.insert(string: "-", index: 8)
                        uuidFormatting = uuidFormatting.insert(string: "-", index: 13)
                        uuidFormatting = uuidFormatting.insert(string: "-", index: 18)
                        uuidFormatting = uuidFormatting.insert(string: "-", index: 23)
                        print("Formatting: \(uuidFormatting)")
                        self.playerUUIDFormatted = uuidFormatting
                    }
                    if let uuidFormatted = json["uuid_formatted"].string {
                        self.playerUUIDFormatted = uuidFormatted
                    }
                    if let nameCaseSensitive = json["name"].string {
                        self.playerName = nameCaseSensitive
                    }
                    if let names = json["history"].array {
                        for index in 0..<names.count {
                            print(index)
                            if let name = names[index]["name"].string {
                                self.names.append(name)
                            }
                            if let name = names[index]["changedToAt"].double {
                                self.dateChanged.append(
                                    "Changed: " + self.dayStringFromUnixTime(name)
                                )
                            } else {
                                self.dateChanged.append("Original")
                            }
                        }
                    }
                    success()
                    print(self.names)
                    print(self.dateChanged)
                }
            }
        }
    }
    
    func fetchNameHistory(_ view: UIView, viewController: UIViewController, uuid: String, success: @escaping () -> ()) {
        Alamofire.request("https://mcapi.de/api/user/\(uuid)").responseJSON { request in
            
            self.hideLoadingHUD(view)
            
            if request.result.error != nil {
                //TODO: Display alert to user? Not too sure how this will work until I implement.
                print("Error occured while performing HTTP request: \(request.result.error!.localizedDescription)")
                self.createAlertController(viewController)
            } else {
                if request.result.value != nil {
                    self.names.removeAll(keepingCapacity: true)
                    self.dateChanged.removeAll(keepingCapacity: true)
                    let json = JSON(request.result.value!)
                    print(json)
                
                    if let result = json["result"]["status"].string {
                        if result == "Error" {
                            self.noUsernameAlert(viewController)
                            self.hideLoadingHUD(view)
                        }
                    }
                    if let names = json["history"].array {
                        for index in 0..<names.count {
                            print(index)
                            if let name = names[index]["name"].string {
                                self.names.append(name)
                            }
                            if let name = names[index]["changedToAt"].double {
                                self.dateChanged.append(
                                    "Changed: " + self.dayStringFromUnixTime(name)
                                )
                            } else {
                                self.dateChanged.append("Original")
                            }
                        }
                    }
                    success()
                    print(self.names)
                    print(self.dateChanged)
                }
            }
        }
    }
    
    func getAvatarIcon() -> UIImage? {
        let url = URL(string: "https://mcapi.ca/avatar/\(self.playerName!)/135")
        
        if let urlNotNil = url,
           let imageData = try? Data(contentsOf: urlNotNil) {
            
            let image = UIImage(data: imageData)
            return image
        }
        return UIImage(named: "SteveIcon.png")
    }
    
    static func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return names.count
    }
    
    func titleForItemAtIndexPath(_ indexPath: IndexPath) -> String {
        return names[indexPath.row]
    }
    
    func subtitleForItemAtIndexPath(_ indexPath: IndexPath) -> String {
        return dateChanged[indexPath.row]
    }
    
    func showLoadingHUD(_ view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Loading..."
    }
    
    func hideLoadingHUD(_ view: UIView) {
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }
    
    func dayStringFromUnixTime(_ unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime / 1000)
        
        // Returns date formatted as 12 hour time
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a z"
        return dateFormatter.string(from: date)
    }
    
    fileprivate func createAlertController(_ view: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "The Minechecker service is currently unavailable, please try again later!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func noUsernameAlert(_ view: UIViewController) {
        let alert = UIAlertController(title: "No Player Found", message: "This username is currently available for use!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            // Perform segue back to main view controller
            view.performSegue(withIdentifier: "backToMain", sender: self)
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
}
