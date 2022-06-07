//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//


import UIKit
import SimpleAlert
import NVActivityIndicatorView

protocol GetTimesUsed {
  func passData(data: Int)
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let imagePredictor = ImagePredictor()

    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var main: UIImageView!
    @IBOutlet weak var shoot: UIImageView!
    @IBOutlet weak var directions: UILabel!
    
    
    var delegate: GetTimesUsed?
    var classifierUsed: Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        directions.alpha = 1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        if delegate != nil {
            delegate?.passData(data: classifierUsed)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
        }
    }
 
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }

    @IBAction func takePhoto(_ sender: Any) {
        self.loadingView.startAnimating()
        self.view.bringSubviewToFront(_: loadingView)
        main.bringSubviewToFront(_: loadingView)
        
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            present(photoPicker, animated: false)
            return
        }

        present(cameraPicker, animated: false)
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dimissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(text:String, conf:Float) {
         var res = text
         if res == "Image is either not a waste or it's too blurry, please try it again."{
             res = "Unclassified"
         }
         let alert = AlertController(view: UIView(), style: .alert)
         alert.contentWidth = 200
         alert.contentCornerRadius = 30
         if #available(iOS 13.0, *) {
             alert.contentColor = .opaqueSeparator
         } else {
             // Fallback on earlier versions
             alert.contentColor = .white
         }
         let action = AlertAction(title: "\(res)", style: .cancel) { action in
         }
         let confView = UILabel(frame:CGRect(x: 0, y: 150, width: 200, height: 35))
         confView.numberOfLines = 2
         confView.text = "Confident Score: \n\(conf)%"
         confView.font = UIFont(name: "Courier", size: 16)
         confView.textAlignment = .center
         action.button.addSubview(confView)
         action.button.bringSubviewToFront(_: confView)
         let classif = UILabel(frame:CGRect(x: 0, y: 120, width: 200, height: 25))
         classif.text = "[ \(res) ]"
         classif.font = UIFont(name: "Courier", size: 20)
         classif.textAlignment = .center
         action.button.addSubview(classif)
         alert.addAction(action)
         action.button.frame.size.height = 200
         action.button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 35)
         var imageName = ""
         if res == "Negative" {
             action.button.setTitleColor(UIColor(red: 135/256, green: 61/256, blue: 61/256, alpha: 1.0), for: .normal)
             action.button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 24)
             imageName = "unclassified.png"
         } else if res == "Landfill" {
             action.button.setTitle("Landfill", for: .normal)
             action.button.setTitleColor(UIColor.black, for: .normal)
             imageName = "trash.png"
             action.button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 33)
         } else if res == "Compost" {
             action.button.setTitle("Compost", for: .normal)
             action.button.setTitleColor(UIColor(red: 57/256, green: 128/256, blue: 68/256, alpha: 1.0), for: .normal)
             imageName = "compost.png"
         } else {
             action.button.setTitle("Recycle", for: .normal)
             action.button.setTitleColor(UIColor(red: 55/256, green: 97/256, blue: 163/256, alpha: 1.0), for: .normal)
             action.button.titleLabel?.font = UIFont(name: "Courier-Bold", size: 32)
             imageName = "recycling.png"
         }
         classif.textColor = action.button.titleColor(for: .normal)
         
         let image = UIImage(named: imageName)
         let imageView = UIImageView(image: image!)
         imageView.frame = CGRect(x: 70, y: 10, width: 60, height: 60)
         action.button.addSubview(imageView)
         imageView.contentMode = .scaleAspectFit

         self.loadingView.stopAnimating()
         self.present(alert, animated: true) {
             let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
             alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
         }
         classifierUsed += 1
     }
}
