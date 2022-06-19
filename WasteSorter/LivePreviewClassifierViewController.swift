//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class LivePreviewClassiferViewController: LivePreviewViewController {
    
    let imagePredictor = ImagePredictor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonView = UIView(frame: CGRect(x: 10, y: 730, width: 60, height: 60))
        buttonView.center.x = self.view.center.x
        buttonView.backgroundColor = UIColor.black
        buttonView.layer.cornerRadius = 15
        self.view.addSubview(buttonView)
        
        let flipButton = UIButton(type: .custom)
        flipButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        flipButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        flipButton.imageView?.tintColor = UIColor.white
        flipButton.contentVerticalAlignment = .fill
        flipButton.contentHorizontalAlignment = .fill
        flipButton.imageView?.contentMode = .scaleAspectFit
        flipButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
        buttonView.addSubview(flipButton)
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer).oriented(_: exifOrientation)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let uiImage = UIImage(cgImage: cgImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.classifyImage(uiImage)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // start the capture
        startCaptureSession()
    }
    
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions - Check console log")
            return
        }

        //debug purpose only
        let formattedPredictions = self.imagePredictor.formatPredictions(predictions)
        let predictionString = formattedPredictions.joined(separator: "\n")
        print("Request is finished - console output:\n", predictionString)
        
        if let conf = Float(predictions[0].confidencePercentage) {
            DispatchQueue.main.async {
                var confidence = conf
                if confidence > 99.9 {
                    confidence = 99.9
                }
                self.displayResults(result: predictions[0].classification, conf: confidence)
            }
        }
    }
    
    private func displayResults(result: String, conf: Float) {
        let view = UIView(frame: CGRect(x: 10, y: 30, width: 330, height: 150))
        view.isOpaque = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.center.x = self.view.center.x
        self.view.addSubview(view)
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        title.center = CGPoint(x: 190, y: 60)
        title.textAlignment = .center
        title.font = UIFont(name: "Courier-Bold", size: 35)
        
        var res = result
        if res == "Image is either not waste or it's too blurry, please try it again."{
            res = "Unclassified"
        }
        var imageName = ""
        if res == "Negative" {
            title.text = "Try Again"
            title.textColor = UIColor(red: 135/256, green: 61/256, blue: 61/256, alpha: 1.0)
            imageName = "unclassified.png"
        } else if res == "Landfill" {
            title.text = "Landfill"
            title.textColor = UIColor.black
            imageName = "trash.png"
        } else if res == "Compost" {
            title.text = "Compost"
            title.textColor = UIColor(red: 57/256, green: 128/256, blue: 68/256, alpha: 1.0)
            imageName = "compost.png"
        } else {
            title.text = "Recycle"
            title.textColor = UIColor(red: 55/256, green: 97/256, blue: 163/256, alpha: 1.0)
            imageName = "recycling.png"
        }
        
        let confView = UILabel(frame:CGRect(x: 0, y: 50, width: 300, height: 35))
        confView.numberOfLines = 1
        confView.text = "Confidence Score: \(conf)%"
        confView.font = UIFont(name: "Courier", size: 20)
        confView.textAlignment = .center
        confView.center = CGPoint(x: 170, y: 110)
        view.addSubview(confView)
        view.bringSubviewToFront(_: confView)
        
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 35, y: 25, width: 60, height: 60)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(title)
    }
}
