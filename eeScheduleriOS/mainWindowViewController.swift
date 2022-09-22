//
//  mainWindowViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn


class mainWindowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tempUsername = String()
    var studentCount : UInt = 0
    let dataRef = Database.database().reference()
    var studentInfo = [studentInformation]()
    var studentNotes = [String]()
    var studentDates = [String]()
    var databaseHandle : DatabaseHandle?
    let userDefault = UserDefaults.standard
    let alertController = UIAlertController(title: "Sign Out", message: "In order to complete Sign-Out, please close the app from the background by double tapping the home button and swiping up on the app", preferredStyle: .alert)
    let action2 = UIAlertAction(title: "Ok", style: .cancel) {
        UIAlertAction in
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    var checkMessage : Bool = false
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        welcomeLabel.text = "Welcome, " + (GIDSignIn.sharedInstance()?.currentUser.profile.givenName)!
        print (studentNotes, studentDates)
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.synchronize()
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentInfo.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! newTableViewCell
        let studentInf: studentInformation
        studentInf = self.studentInfo[indexPath.row]
        cell.nameLabel.text = studentInf.nameID
        cell.tutorLabel.text = studentInf.tutorID
        let urlTempURL = URL(string: (studentInf.imageURL)!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: urlTempURL!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.photoView.image = UIImage(data: data!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "selectedCell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is addStudentViewController {
            if let nextViewController = segue.destination as? addStudentViewController {
                nextViewController.tempStudentInfo = studentInfo
            }
        }
        if segue.destination is specificCellViewController {
            print (Int((tableView.indexPathForSelectedRow?.row)!))
            if let nextViewController = segue.destination as? specificCellViewController {
                nextViewController.studentInfo = studentInfo
                nextViewController.studentNumber = Int((tableView.indexPathForSelectedRow?.row)!)
                nextViewController.indexSelected = (tableView.indexPathForSelectedRow?.row)!
                nextViewController.studentNotes = studentNotes
                nextViewController.studentDates = studentDates
            }
        }
    }
}

