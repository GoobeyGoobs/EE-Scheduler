//
//  retrieveDataViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn
import MessageUI
import EventKit
import EventKitUI

class retrieveDataViewController: UIViewController {
    let dataRef = Database.database().reference()
    var studentInfo = [studentInformation]()
    var studentDates = [String]()
    var studentNotes = [String]()
    var databaseHandle : DatabaseHandle?
    var complete = false
    var countComplete = false
    let ref1 = Database.database().reference().child("teachers").child((GIDSignIn.sharedInstance()?.currentUser.profile.name)!)
    //Traverses the database all the way down to the user, who's node is named after them
    var childrenCount = 0
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        loadingIndicator.startAnimating()
        super.viewDidLoad()
        studentInfo.removeAll()
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            print (snapshot.exists())
            if snapshot.exists() {
            self.childrenCount = Int(snapshot.childrenCount)
            if self.childrenCount == 0 {
                self.childrenCount = self.childrenCount + 1
            }
            for i in 1...self.childrenCount {
                let ref = Database.database().reference().child("teachers").child((GIDSignIn.sharedInstance()?.currentUser.profile.name)!).child("student" + String(i))
                ref.child("lastMeetNotes").observeSingleEvent(of: .value, with: {(snapshot1 : DataSnapshot) in
                    if snapshot1.exists() {
                        if snapshot1.value is NSNull {
                            self.studentNotes.append("None")
                        } else {
                            self.studentNotes.append(snapshot1.value as! String)
                        }
                    } else {
                        print ("failed")
                    }
                }, withCancel: nil)
                ref.child("lastMeetDate").observeSingleEvent(of: .value, with: {(snapshot2 : DataSnapshot) in
                    if snapshot2.exists() {
                        if snapshot2.value is NSNull {
                            self.studentDates.append("None")
                        } else {
                            self.studentDates.append(snapshot2.value as! String)
                        }
                    } else {
                        print ("failed")
                    }
                }, withCancel: nil)
                ref.observeSingleEvent(of: .value, with: { (snapshot : DataSnapshot) in
                    if snapshot.exists() {
                        let dictionary = snapshot.value as! [String : String]
                        self.studentInfo.append(studentInformation(nameID: dictionary["nameID"], tutorID: dictionary["tutorID"], imageURL: (dictionary["photoID"]), emailID : (dictionary["emailID"])))
                        if (i == self.childrenCount) {
                            self.complete = true
                        }
                        if self.complete == true {
                            _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                                self.loadingIndicator.stopAnimating()
                                self.performSegue(withIdentifier: "gottenInformation", sender: self)
                            }
                        }
                    }
                }, withCancel: nil)
            }
            } else {
                sleep(3)
                self.loadingIndicator.stopAnimating()
                self.performSegue(withIdentifier: "gottenInformation", sender: self)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is mainWindowViewController {
            if let nextViewController = segue.destination as? mainWindowViewController {
                nextViewController.studentInfo = studentInfo
                nextViewController.studentNotes = studentNotes
                nextViewController.studentDates = studentDates
                
            }
        }
    }
}

