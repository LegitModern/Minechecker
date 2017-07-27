//
//  SavedSearchesTableViewController.swift
//  Minechecker
//
//  Created by Ryan Donaldson on 8/14/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD
import FirebaseAnalytics

class SavedSearchesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    let realm = try! Realm()
    
    var minecraftAccount: MinecraftAccount?
    var indexCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let results = realm.objects(MinecraftSearch.self).sorted(byKeyPath: "dateDouble", ascending: true)
        Analytics.logEvent("visited_saved_searches", parameters: ["results": results.count as NSObject])
        
        // Do any additional setup after loading the view, typically from a nib.
        configureTableView()
        
       /* self.showLoadingHUD(view)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
            self.tableView.reloadData()
            self.hideLoadingHUD(self.view)
        } */
        indexCount = Int(results.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailFromSearches" {
            let root = segue.destination as! NameHistoryTableViewController
            if let minecraftAccountExists = minecraftAccount {
                root.minecraftAccount = minecraftAccountExists
            }
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return indexCount
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let indexPathRow = indexPath.row
            let results = realm.objects(MinecraftSearch.self).sorted(byKeyPath: "dateDouble", ascending: true)
            let realmResult = results[indexPathRow]
            do {
                try realm.write {
                    realm.delete(realmResult)
                }
            } catch {
                let errorAlert = UIAlertController(title: "Error", message: "An error occured while attempting to delete this search. Please try again!", preferredStyle: UIAlertControllerStyle.alert)
                errorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            self.indexCount = self.indexCount - 1
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SavedSearchesTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let realmResult = results.objectAtIndex(UInt(indexPath.row)) as? MinecraftSearch {
//            minecraftAccount = MinecraftAccount(playerName: realmResult.name)
//            self.performSegueWithIdentifier("toDetailFromSearches", sender: self)
//        }
    
        let fromRect: CGRect = self.tableView.rectForRow(at: indexPath)
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "NameHistoryTableViewController") as! NameHistoryTableViewController
        
        let results = realm.objects(MinecraftSearch.self).sorted(byKeyPath: "dateDouble", ascending: true)
        let realmResult = results[indexPath.row]
        let minecraftAccountDB = MinecraftAccount(playerName: realmResult.name)
        vc.minecraftAccount = minecraftAccountDB
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popoverController = vc.popoverPresentationController!
        popoverController.delegate = self
        popoverController.sourceView = self.view
        popoverController.sourceRect = fromRect
        popoverController.permittedArrowDirections = UIPopoverArrowDirection.any
        present(vc, animated: true, completion: nil)
    }
    
    func configureCell(_ cell: SavedSearchesTableViewCell, atIndexPath indexPath: IndexPath) {
        let results = realm.objects(MinecraftSearch.self).sorted(byKeyPath: "dateDouble", ascending: true)
        let realmResult = results[indexPath.row]
        print(realmResult)
        cell.playerName.text = "\(realmResult.name)"
        cell.dateSearchedLabel.text = "\(realmResult.date)"
    }
    
    func configureTableView() {
        // Set Custom Gradient Background
        self.tableView.backgroundView = GradientBackgroundView()
        
        // Custom Table View Row Height
        self.tableView.rowHeight = 57
        
        // Custom Selector Background Color
        self.tableView.separatorColor = UIColor.white
    }
    
    func showLoadingHUD(_ view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Loading..."
    }
    
    func hideLoadingHUD(_ view: UIView) {
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        navigationController.navigationBar.barTintColor = UIColor(rgba: "#f07b57")
        navigationController.navigationBar.barStyle = UIBarStyle.default
        navigationController.navigationBar.isTranslucent = true
        navigationController.topViewController!.navigationItem.title = nil
        let btnDone = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SavedSearchesTableViewController.dismissView))
        navigationController.topViewController!.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
