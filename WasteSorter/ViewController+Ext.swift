//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//


import UIKit

extension ViewController {
    // MARK: Main storyboard updates
    /// Updates the storyboard's image view.
    /// - Parameter image: An image.
    func updateImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.directions.alpha = 1
//            self.main.image = image
            let imageView = UIImageView(frame: self.view.bounds)
            imageView.image = image
            self.view.addSubview(imageView)
            imageView.alpha = 0.7
            self.view.bringSubviewToFront(self.directions)
            self.view.bringSubviewToFront(self.main)
            self.view.bringSubviewToFront(self.shoot)
            self.view.bringSubviewToFront(self.classifierTitle)
            self.loadingView.stopAnimating()
        }
    }

    /// Notifies the view controller when a user selects a photo in the camera picker or photo library picker.
    /// - Parameter photo: A photo from the camera or photo library.
    func userSelectedPhoto(_ photo: UIImage) {
        updateImage(photo)

        DispatchQueue.global(qos: .userInitiated).async {
            self.classifyImage(photo)
        }
    }
    
}

extension ViewController {
    // MARK: Image prediction methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
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
        let formattedPredictions = formatPredictions(predictions)
        let predictionString = formattedPredictions.joined(separator: "\n")
        print("Request is finished - console output:\n", predictionString)
        
        if let conf = Float(predictions[0].confidencePercentage) {
            DispatchQueue.main.async {
                print(predictions[0])
                self.showAlert(text: predictions[0].classification, conf: conf)
            }
        }
    }

    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        /// The largest number of predictions the main view controller displays the user.
        let predictionsToShow = 3
       
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"

        }
        return topPredictions
    }
}
