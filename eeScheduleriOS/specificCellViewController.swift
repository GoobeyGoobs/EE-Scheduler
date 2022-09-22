//
//  specificCellViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn

class specificCellViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tutorLabel: UILabel!
    @IBOutlet var photoLabel: UIImageView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var lastMeedDate: UILabel!
    @IBOutlet weak var lastMeetNotesLabel: UILabel!
    
    var tempPhotoURL = String()
    var indexSelected = Int()
    var studentInfo = [studentInformation]()
    var studentNumber = Int()
    var studentNotes = [String]()
    var studentDates = [String]()
    
    override func viewDidLoad() {
        print (studentDates, indexSelected)
        let studentInf = studentInfo[indexSelected]
        nameLabel.text = studentInf.nameID
        tutorLabel.text = studentInf.tutorID
        tempPhotoURL = studentInf.imageURL!
        formatLabel()
        super.viewDidLoad()
        let urlTempURL = URL(string: tempPhotoURL)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: urlTempURL!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.photoLabel.image = UIImage(data: data!)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func formatLabel() {
        lastMeedDate.text = studentDates[indexSelected]
        lastMeetNotesLabel.text = studentNotes[indexSelected]
        lastMeetNotesLabel.numberOfLines = 0
        lastMeetNotesLabel.sizeToFit()
    }
    
    @IBAction func backToTable(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextViewController = segue.destination as? newMeetingViewController {
            nextViewController.studentInfo = studentInfo
            nextViewController.indexSelected = indexSelected
        }
    }
}
