//
//  NameHistoryTableViewController.swift
//  Minehistory
//
//  Created by Ryan Donaldson on 7/22/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAnalytics

class NameHistoryTableViewController: UITableViewController {

    @IBOutlet weak var playerIcon: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var migratedLabel: UILabel!
    
    var minecraftAccount: MinecraftAccount?
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAnalytics.logEvent(withName: "visited_name_history", parameters: ["account_name": (minecraftAccount?.playerName)! as NSObject])

        // Do any additional setup after loading the view, typically from a nib.
        configureTableView()
        
        if let minecraftAccountExists = minecraftAccount {
            minecraftAccountExists.showLoadingHUD(self.view)
            
            minecraftAccountExists.fetchItems(self.view, viewController: self, success: { () -> () in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.playerName.text = minecraftAccountExists.playerName!
                    if let uuidExists = minecraftAccountExists.playerUUIDFormatted {
                        self.uuidLabel.text = "UUID: \(uuidExists)"
                    } else {
                        self.uuidLabel.text = "UUID: Unknown"
                    }
        
                    self.tableView.reloadData()
                })
            })
            
            let url = URL(string: "https://mcapi.ca/avatar/\(minecraftAccountExists.playerName!)/135")!
            self.playerIcon.download(from: url, contentMode: .scaleAspectFit, placeholder: UIImage(named: "SteveIcon.png"), completionHandler: { (image, error) in
                
                if error != nil {
                    print("Could not download image from URL: \(error?.localizedDescription)")
                } else {
                    print("Successfully downloaded image!")
                    DispatchQueue.main.async {
                        minecraftAccountExists.hideLoadingHUD(self.view)
                    }
                }
            })
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.clear
        self.refreshControl?.tintColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(NameHistoryTableViewController.reloadTableWithData), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveClicked(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Save Search", message: "Would you like to save this search to view later?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
            
            let dateNow = Date()
            
            let search = MinecraftSearch()
            search.name = self.minecraftAccount!.playerName!
            search.dateDouble = dateNow.timeIntervalSince1970
            search.date = "Searched on: " + self.dayStringFromUnixTime(dateNow.timeIntervalSince1970)
            
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.add(search)
                }
            } catch {
                let errorAlert = UIAlertController(title: "Error", message: "An error occured while attempting to save your search. Please try again!", preferredStyle: UIAlertControllerStyle.alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }

            let results = realm.objects(MinecraftSearch.self).sorted(byKeyPath: "dateDouble", ascending: true)
            print(results)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return MinecraftAccount.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let minecraftAccountExists = minecraftAccount {
            return minecraftAccountExists.numberOfItemsInSection(section)
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NameHistoryTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: NameHistoryTableViewCell, atIndexPath indexPath: IndexPath) {
        cell.playerName.text = minecraftAccount?.titleForItemAtIndexPath(indexPath)
        cell.nameChangedLabel.text = minecraftAccount?.subtitleForItemAtIndexPath(indexPath)
    }
    
    func configureTableView() {
        // Set Custom Gradient Background
        self.tableView.backgroundView = GradientBackgroundView()
        
        // Custom Table View Row Height
        self.tableView.rowHeight = 57
        
        // Custom Selector Background Color
        self.tableView.separatorColor = UIColor.white
    }
    
   func reloadTableWithData() {
        minecraftAccount?.showLoadingHUD(self.view)
        minecraftAccount?.fetchNameHistory(self.view, viewController: self, uuid: minecraftAccount!.playerUUID!, success: { () -> () in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                
                if let refresher = self.refreshControl {
                    self.dateFormatter.dateFormat = "MMM d, h:mm a"
                    let date = Date()
                    let todaysDate = self.dateFormatter.string(from: date)
                    let lastUpdated = "Last update: \(todaysDate)"
                    
                    let attributesDictionary = NSDictionary(object: UIColor.white, forKey: NSForegroundColorAttributeName as NSCopying)
                    let attributeString = NSAttributedString(string: lastUpdated, attributes: attributesDictionary as? [String: AnyObject])
                    refresher.attributedTitle = attributeString
                    
                    refresher.endRefreshing()
                }
            })
        })
    }
    
    func dayStringFromUnixTime(_ unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        
        // Returns date formatted as 12 hour time
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm a z"
        return dateFormatter.string(from: date)
    }
}
