//
//  ViewController.swift
//  Minechecker
//
//  Created by Ryan Donaldson on 7/22/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var playerTextField: UITextField?
    var minecraftAccount: MinecraftAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        playerTextField?.setTextLeftPadding(7)
        playerTextField?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        playerTextField?.textColor = UIColor(rgba: "#F9845B")
        
        configureView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= 16
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        if sender.tag == 0 {
            if let textFieldExists = playerTextField {
                print(textFieldExists.text!)
                if textFieldExists.text!.isEmpty {
                    enterTextAlert(self)
                } else {
                    minecraftAccount = MinecraftAccount(playerName: textFieldExists.text!)
                    view.endEditing(true)
                    self.performSegue(withIdentifier: "toDetail", sender: self)
                }
            }
        }
    }
    
    @IBAction func savedSearchesPressed(_ sender: AnyObject) {
        if sender.tag == 1 {
            self.showLoadingHUD(self.view)
            self.performSegue(withIdentifier: "toSearch", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let root = segue.destination as! NameHistoryTableViewController
            if let minecraftAccountExists = minecraftAccount {
                root.minecraftAccount = minecraftAccountExists
            }
        } else if segue.identifier == "toSearch" {
            self.hideLoadingHUD(self.view)
        }
    }
    
    @IBAction
    func resetViewController(_ segue: UIStoryboardSegue) {
        print("Returning to ViewController...", terminator: "")
    }
    
    func configureView() {
        // Custom Text Field Font
        playerTextField?.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        
        // Custom Navigarion Bar Font/Color To Match Theme
        if let navbarFont = UIFont(name: "HelveticaNeue-Light", size: 20.0) {
            let navbarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: navbarFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = navbarAttributesDictionary
        }
        
        // Configure Navigation Bar Back Button
        if let buttonFont = UIFont(name: "HelveticaNeue-Light", size: 20.0) {
            let barButtonAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: buttonFont
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributesDictionary, for: UIControlState())
        }
        
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showLoadingHUD(_ view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Loading..."
    }
    
    func hideLoadingHUD(_ view: UIView) {
        MBProgressHUD.hideAllHUDs(for: view, animated: true)
    }
    
    fileprivate func enterTextAlert(_ view: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "You cannot continue without entering text! Please try again!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
}

