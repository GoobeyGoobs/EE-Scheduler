//
//  addStudentViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn
import Photos
import AVFoundation

class addStudentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var nameLabelInput: UITextField!
    @IBOutlet var mentorLabelInput: UITextField!
    @IBOutlet var schoolLabelInput: UITextField!
    var ref = Database.database().reference()
    var imagePicker = UIImagePickerController()
    var tempStudentInfo = [studentInformation]()
    var selectedImage: UIImage?
    var completedSaveImage : Bool = false
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func takeImage(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: AnyObject) {
        guard let selectedImage = imagePreview.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    @IBAction func addStudentButton(_ sender: Any) {
        self.saveFIRData()
//        performSegue(withIdentifier: "reloadDatabase", sender: self)
    }
    
    @IBAction func cancelAddStudent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func saveFIRData() {
        self.uploadImage(self.imagePreview.image!) { url in
            self.saveImageToDatabase(nameID: self.nameLabelInput.text!, tutorID: self.mentorLabelInput.text!, emailID: self.schoolLabelInput.text!, photoID: url!) { success in
                if success != nil {
                    print ("Succeeded in saving image")
                }
            }
        }
    }
    
    @IBAction func imagePicker(_ sender: Any) {
        checkPermission()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.selectedImage = editedImage
            imagePreview.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectedImage = originalImage
            imagePreview.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}


extension addStudentViewController {
    
    func uploadImage(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        let storageRef = Storage.storage().reference().child(String(self.schoolLabelInput.text!) + String(self.tempStudentInfo.count) + ".png")
        let imgData = imagePreview.image!.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metadata, completion: { (metadata, error) in
            if error == nil {
                print ("success")
                storageRef.downloadURL(completion: {(url, error) in
                    completion(url)
                    self.completedSaveImage = true
                })
            } else {
                print ("Error saving image")
                completion(nil)
            }
        })
    }
    
    func saveImageToDatabase(nameID: String, tutorID: String, emailID: String, photoID: URL, completion: @escaping ((_ url: URL?) -> ())) {
        self.ref.child("teachers").child((GIDSignIn.sharedInstance()?.currentUser.profile.name)!).child("student" + String(self.tempStudentInfo.count + 1)).setValue(["nameID" : nameID, "tutorID" : tutorID, "emailID" : emailID, "photoID" : photoID.absoluteString, "lastMeetDate" : "None", "lastMeetNotes" : "None"])
    }
    
}
