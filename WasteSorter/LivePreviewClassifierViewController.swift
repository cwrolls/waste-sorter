//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class LivePreviewClassiferViewController: LivePreviewViewController {
    
    let imagePredictor = ImagePredictor()
    
    
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
                //self.showAlert(text: predictions[0].classification, conf: conf)
                var confidence = conf
                if confidence > 99.9 {
                    confidence = 99.9
                }
                self.displayResults(result: predictions[0].classification, conf: confidence)
            }
        }
    }
    
}
