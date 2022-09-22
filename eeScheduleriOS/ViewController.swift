//
//  ViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet var welcomeLabel: UILabel!

    
    override func viewDidLoad() {
        GIDSignIn.sharedInstance()?.uiDelegate = self
        super.viewDidLoad()
    }
}

