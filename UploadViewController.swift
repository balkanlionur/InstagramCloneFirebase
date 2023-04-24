//
//  UploadViewController.swift
//  InstagramCloneFirebase
//
//  Created by Admin on 17.04.2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var imageText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)

        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){

    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    picker.allowsEditing = true
    present(picker, animated: true,completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        
       // saveButton.isEnabled = true
        
        self.dismiss(animated: true,completion: nil)
    }
    
    func  makeAlert(titleInput: String, messageInput: String ) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func uploadClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        
        let mediaFolder = storageReferance.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { metadata, error in
                if error != nil{
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                }else{
                    
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                           
                            // Firestore Database
                            
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReferance : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl": imageUrl! , "postedby" : Auth.auth().currentUser!.email! , "postComment": self.imageText.text! , "date" : FieldValue.serverTimestamp() , "likes" : 0 ] as [String : Any]
                            
                            firestoreReferance = firestoreDatabase.collection("Posts").addDocument(data: firestorePost , completion: { error in
                                if error != nil {
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error !!!")
                                }else{
                                    self.imageView.image = UIImage(named: "Image.jpg")
                                    self.imageText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                    
                                }
                                    
                            })
                            
                            
                            
                            
                        }
                    }
                }
            }
            
            
        }
        
        
    }
    
}



