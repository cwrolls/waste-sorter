//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//



import UIKit
import AVFoundation
import Vision

class LivePreviewViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    @IBOutlet weak private var previewView: UIView!
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    var usingFrontCamera = true
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func displayResults(result: String, conf: Float) {
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
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
        @objc func switchCameraTapped(sender: Any) {
        //Change camera source
            let thisSession = session
            //Indicate that some changes will be made to the session
            thisSession.beginConfiguration()

            //Remove existing input
            let currentCameraInput:AVCaptureInput = session.inputs.first!
            thisSession.removeInput(currentCameraInput)

            //Get new input
            var newCamera:AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back)
                {
                    newCamera = cameraWithPosition(position: .front)
                }
                else
                {
                    newCamera = cameraWithPosition(position: .back)
                }

            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }

            if(newVideoInput == nil || err != nil)
            {
                print("Error creating capture device input: \(err!.localizedDescription)")
            }
            else
            {
                session.addInput(newVideoInput)
            }

            //Commit all the configuration changes at once
            session.commitConfiguration()
        }
    }

    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice?
    {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                           mediaType: AVMediaType.video,
                                                                           position: AVCaptureDevice.Position.unspecified)
            for device in deviceDescoverySession.devices {
                if device.position == position {
                    return device
                }
            }
        return nil
    }
}
