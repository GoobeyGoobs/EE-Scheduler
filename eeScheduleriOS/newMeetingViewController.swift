//
//  newMeetingViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import MessageUI
import GoogleSignIn
import EventKit
import Foundation

class newMeetingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var indexSelected = Int()
    var formattedDate = String()
    @IBOutlet var notesBox: UITextView!
    @IBOutlet var homeworkBox: UITextView!
    @IBOutlet weak var currDate: UILabel!
    var studentInfo = [studentInformation]()
    @IBOutlet var nextMeet: UITextField!
    @IBOutlet var hourTime: UITextField!
    @IBOutlet var endTime: UITextField!
    let eventStore = EKEventStore()
    private var datePicker = UIDatePicker()
    private var rawStartTime = Date()
    private var rawEndTime = Date()
    private var rawDate = Date()
    
    @IBAction func completeButton(_ sender: Any) {
        sendEmail()
        assignCalender()
    }
    
    func assignCalender() {
        let tempInfo = studentInfo[indexSelected]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyyHH:mm"
        let startTime = nextMeet.text! + hourTime.text!
        let endingTime = nextMeet.text! + endTime.text!
        print (startTime)
        dateFormatter.locale = Locale(identifier: "en_US")
        let startDate:Date = dateFormatter.date(from: startTime)!
        let endDate:Date = dateFormatter.date(from: endingTime)!
        addEventToCalendar(title: "Next EE meeting with " + String(tempInfo.emailID!), description: "EE Meeting on " + String(self.formattedDate), startDate: startDate, endDate: endDate)
        }
    
    
    func datePickerBox() {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        nextMeet.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(newMeetingViewController.dateChanged(datePicker1:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newMeetingViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dateChanged(datePicker1: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        nextMeet.text = dateFormatter.string(from: datePicker1.date)
        rawDate = datePicker1.date
        view.endEditing(true)
    }
    
    func timePickerBox() {
        let startTimePickerView = UIDatePicker()
        startTimePickerView.datePickerMode = .time
        hourTime.inputView = startTimePickerView
        startTimePickerView.addTarget(self, action: #selector(newMeetingViewController.timeChanged(datePicker:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newMeetingViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func timeChanged(datePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        hourTime.text = timeFormatter.string(from: datePicker.date)
        rawStartTime = datePicker.date
        view.endEditing(true)
    }
    

    func endTimePickerBox() {
        let endTimePickerView = UIDatePicker()
        endTimePickerView.datePickerMode = .time
        endTime.inputView = endTimePickerView
        endTimePickerView.addTarget(self, action: #selector(newMeetingViewController.endTimeChanged(datePicker2:)), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newMeetingViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func endTimeChanged(datePicker2: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        endTime.text = timeFormatter.string(from: datePicker2.date)
        rawEndTime = datePicker2.date
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerBox()
        timePickerBox()
        endTimePickerBox()
        self.notesBox.layer.borderColor = UIColor.lightGray.cgColor
        self.notesBox.layer.borderWidth = 1
        self.homeworkBox.layer.borderColor = UIColor.lightGray.cgColor
        self.homeworkBox.layer.borderWidth = 1
        notesBox.text = ("Type any notes from the meeting here...")
        homeworkBox.text = ("Type the task which is to be set for the next meeting...")
        getDate()
        self.hideKeyboardWhenTappedAround()
    }
    
    func getDate() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        formattedDate = format.string(from: date)
        currDate.text = formattedDate
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            print ("opening")
            let tempInfo = studentInfo[indexSelected]
            let emailID = tempInfo.emailID! + "@gapps.uwcsea.edu.sg"
            print (emailID)
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailID])
            mail.setSubject("EE Meeting on " + String(self.formattedDate))
            mail.setMessageBody("Notes on Meeting: " + String(notesBox.text) + "\nHomework is: " + String(homeworkBox.text), isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            let tempInfo = studentInfo[indexSelected]
            let emailID = tempInfo.emailID! + "@gapps.uwcsea.edu.sg"
            print (emailID)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue :
            print("Cancelled")
        case MFMailComposeResult.failed.rawValue :
            print("Failed")
        case MFMailComposeResult.saved.rawValue :
            print("Saved")
        case MFMailComposeResult.sent.rawValue :
            print("Sent")
        default: break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func requestCalender() {
        switch EKEventStore.authorizationStatus(for: .event) {

        case .authorized:
            print("Authorized")

        case .denied:
            print("Access denied")

        case .notDetermined:
            eventStore.requestAccess(to: .event, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted {
                        print("Access granted")
                    } else {
                        print("Access denied")
                    }
            })

            print("Not Determined")
        default:
            print("Case Default")
        }
    }
    

}

//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//extension ViewController: MFMailComposeViewControllerDelegate {
//
//            func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//
//                if let _ = error {
//                    //Show error alert
//                    controller.dismiss(animated: true)
//                    return
//                }
//
//                switch result {
//                case .cancelled:
//                    print("Cancelled")
//                    controller.dismiss(animated: true)
//                case .failed:
//                    print("Failed to send")
//                case .saved:
//                    print("Saved")
//                case .sent:
//                    print("Email Sent")
//                    controller.dismiss(animated: true)
//                @unknown default:
//                    break
//                }
//
//             controller.dismiss(animated: true)
//        }
//}
//
