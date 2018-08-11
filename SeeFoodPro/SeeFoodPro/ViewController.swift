//
//  ViewController.swift
//  SeeFoodPro
//
//  Created by Eric Andersen on 5/17/18.
//  Copyright © 2018 Eric Andersen. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social
import TwitterKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "f6b43dc0b4af25e5835959f6c53187c549be66e1"
    let version = "2018-05-18"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topBarImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
//            let composer = TWTRComposerViewController(initialText: "Check out this great image: ", image: image, videoURL:fileURL)
//            composer.delegate = self as? TWTRComposerViewControllerDelegate
//            present(composer, animated: true, completion: nil)
            
            visualRecognition.classify(image: image, success: { (classifiedImages) in                   let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = true
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
            })
            
        } else {
            print("There was an error picking the image")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title!)")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)

        } else {
            self.navigationItem.title = "Please log in to Twitter"
        }

    }
        
//        let composer = TWTRComposer()
//
//        composer.setText("My food is \(navigationItem.title!)")
//        composer.setImage(UIImage(named: "hotdogBackground"))
//
//        // Called from a UIViewController
//        composer.show(from: self.navigationController!) { (result in
//            if (result == .done) {
//            print("Successfully composed Tweet")
//            } else {
//            print("Cancelled composing")
//            }
//        }
//}
}

