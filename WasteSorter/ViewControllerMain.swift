//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//


import UIKit
import Gifu

class ViewControllerMain: UIViewController, UIPopoverPresentationControllerDelegate, GIFAnimatable, GetTimesUsed {
    
    // Keep this here, no idea what this does
    lazy var layer: CALayer = gifView.layer
    var frame: CGRect = UIScreen.main.bounds
    var contentMode: UIView.ContentMode = .scaleToFill
    
    public lazy var animator: Animator? = {
       return Animator(withDelegate: self)
     }()

    public func display(_ layer: CALayer) {
       updateImageIfNeeded()
    }
    
    lazy var gifView: CustomAnimatedView = {
        return CustomAnimatedView(frame: UIScreen.main.bounds)
    }()
    
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoBottom: NSLayoutConstraint!
    @IBOutlet weak var directions: UILabel!
    @IBOutlet weak var gradientBar: UIImageView!
    @IBOutlet weak var scoreBox: UIImageView!
    @IBOutlet weak var trashScore: UILabel!
    var appLaunch: Date!
    let firstLaunchOccurred = UserDefaults.standard
    var usedCount: Int! = 0
    var countForScore: Int! = 0
    var newLaunch: Bool! = true
    
    let messages = [
        "Your earth is dying! This air is hardly breathable, and the landfills can't keep up with the demand! Don't worry, you can save your planet by sorting your trash. Just swipe left and open the Waste Classifier. Let's work towards a green globe!",
        
        "Hmm... something doesn't look right here. Your earth is becoming more polluted—trash is piling up on the streets, the air is smoggy, and people can't go outside without wearing masks! We need to fix this, ASAP!",
                    
        "Your earth isn't doing bad, but it could be better. I still see tons of recyclable items in the landfill...no, this won't do! If we keep going this way, our earth will be doomed for sure! If you use the Waste Classifier more, maybe you'll help build a cleaner and greener earth.",
        
        "This is definitely an improvement from before. Although there's still trash on the side of the road, drinking water is now cleaner, and there's less smog in the city. Keep sorting your trash!",
        
        "You're on the right track! The landfills are emtpying out, and the air is clearing up. What a great time to go for a walk in the park! Still, there's some room for improvement—keep using the Waste Classifier to improve your Earth!",
        
        "Wow, your earth is doing great! Let's take a moment to breathe in the fresh air...mmmm...look at all this greenery! Make sure to maintain this clean environment by coming back often to use the Waste Classifier."]
    
    @IBAction func tapScorebox(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "introTwoVC")
        vc.modalPresentationStyle = .popover
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        performSegue(withIdentifier: "toPic", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPic" {
            let vc2 : ViewController = segue.destination as! ViewController
            vc2.delegate = self
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        performSegue(withIdentifier: "toLive", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // bugbug
        // NotificationCenter.default.addObserver(self, selector:#selector(updateView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: NSNotification.Name(rawValue: "NotificationID"), object: nil)
    
        // Arrange layer order
        view.addSubview(gifView)
        view.bringSubviewToFront(_: directions)
        view.bringSubviewToFront(_: scoreBox)
        view.bringSubviewToFront(_: trashScore)
        view.bringSubviewToFront(_: gradientBar)
        view.bringSubviewToFront(_: infoButton)
        
        appLaunch = Date()
        updateView()
        newLaunch = false
        UserDefaults.standard.set(Date(), forKey: "Quit Date")
        directions.alpha = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
            self.directions.alpha = 0.7
        }
    }
    
    // MARK: Delegate Functions

    @objc func passData(data: Int) {
        usedCount += data
        countForScore += data
        print("Count was passed.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if firstLaunchOccurred.bool(forKey: "First Launch") == true {
            print("Not first launch.")
        } else {
            print("First launch.")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "introOneVC")
            vc.modalPresentationStyle = .popover
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
            self.view.mask = UIView(frame: self.frame)
            self.view.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            UserDefaults.standard.set(3, forKey: "Current Color")
            UserDefaults.standard.set(50, forKey: "Current Trash Score")
            firstLaunchOccurred.set(true, forKey: "First Launch")
        }
    }
    
    // MARK: Update Gif
    
    func getGifName() -> String {
        let currColor = UserDefaults.standard.integer(forKey: "Current Color")
        var timeSpan: TimeInterval!
        var hoursBetween: Int!
        var score: Int! = 0
        let dateQuit = UserDefaults.standard.object(forKey: "Quit Date") as? Date ?? nil
        if dateQuit != nil {
            timeSpan = appLaunch.timeIntervalSince(dateQuit!)
            hoursBetween = (Int(timeSpan! / 3600))
        } else {
            return "EarthWhite"
        }
        let gifs = ["EarthRed", "EarthRedOrange", "EarthOrange", "EarthWhite", "EarthYellowGreen", "EarthGreen"]
        
        if newLaunch {
            var myColor = currColor
            if !firstLaunchOccurred.bool(forKey: "First Launch") {
                return "EarthWhite"
            } else if hoursBetween < 5 {
                
            } else if hoursBetween < 11 {
                myColor -= 1
            } else if hoursBetween < 17 {
                myColor -= 2
            } else if hoursBetween < 27 {
                myColor -= 3
            } else if hoursBetween < 38 {
                myColor -= 4
            } else {
               myColor = 0
            }
            if (myColor <= 0) {
                myColor = 0
            }
            UserDefaults.standard.set(myColor, forKey: "Current Color")
            return gifs[myColor]
        } else {
            if usedCount == 3 {
                score = 1
                usedCount = 0
            }
            print("Used Count = " + String(usedCount))
            if currColor != 5 && score == 1 {
                if currColor == 4 {
                    UserDefaults.standard.set(5, forKey: "Current Color")
                    return gifs[5]
                } else if currColor == 3 {
                    UserDefaults.standard.set(4, forKey: "Current Color")
                    return gifs[4]
                } else if currColor == 2 {
                    UserDefaults.standard.set(3, forKey: "Current Color")
                    return gifs[3]
                } else if currColor == 1 {
                    UserDefaults.standard.set(2, forKey: "Current Color")
                    return gifs[2]
                } else {
                    UserDefaults.standard.set(1, forKey: "Current Color")
                    return gifs[1]
                }
            } else {
                return gifs[currColor]
            }
        }
    }
    func getTrashScore() -> Int {
        let numTrashScore = UserDefaults.standard.integer(forKey: "Current Trash Score")
        var timeSpan: TimeInterval!
        var hoursBetween: Int!
        var canIncreaseScore: Int! = 0
        let dateQuit = UserDefaults.standard.object(forKey: "Quit Date") as? Date ?? nil
        if dateQuit != nil {
            timeSpan = appLaunch.timeIntervalSince(dateQuit!)
            hoursBetween = (Int(timeSpan! / 3600))
        } else {
            return 50
        }
        
        if newLaunch {
            var score = numTrashScore
            if !firstLaunchOccurred.bool(forKey: "First Launch") {
                return 50
            } else if hoursBetween < 5 {
                
            } else if hoursBetween < 11 {
                score -= Int.random(in: 7..<15)
            } else if hoursBetween < 17 {
                score -= Int.random(in: 13..<21)
            } else if hoursBetween < 27 {
                score -= Int.random(in: 19..<35)
            } else if hoursBetween < 38 {
                score -= Int.random(in: 31..<47)
            } else {
               score = 1
            }
            print("Score = 1" + String(score))
//            if (score < 0) {
//                score = 0
//            }
            UserDefaults.standard.set(score, forKey: "Current Trash Score")
            return score
        } else {
            if countForScore == 3 {
                canIncreaseScore = 1
                countForScore = 0
            }
            if numTrashScore != 100 && canIncreaseScore == 1 {
                var newScore: Int! = numTrashScore + Int.random(in: 9..<21)
                if newScore > 100 {
                    newScore = 100
                }
                UserDefaults.standard.set(newScore, forKey: "Current Trash Score")
                print("Score 2 = " + String(newScore))
                return newScore
            } else {
                print("Score 3 = " + String(numTrashScore))
                return numTrashScore
            }
        }
    }
        
        
    
    @objc func updateView() {
        let name = getGifName()
        // gifView.image = UIImage(named: "\(name).png")
        // gifView.loadGif(name: name)
        gifView.animate(withGIFNamed: name)
        let score = getTrashScore()
        trashScore.text = "\(score)%"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Info Button
    
    @IBAction func infoClicked(_ sender: UIButton) {
        if infoButton.currentImage == UIImage(named: "info2") {
            self.dismiss(animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.infoBottom.constant -= 80
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            
            UIView.animate(withDuration: 1, animations: {
                self.gifView.alpha = 1
            })
            
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.infoBottom.constant += 80
                self.view.layoutIfNeeded()
            }, completion: nil)

            showPopover()
        }
        
        if sender.currentImage == UIImage(named: "info2") {
            sender.setImage(UIImage(named: "info"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "info2"), for: .normal)
        }
    }
    
    // MARK: Popover
  
   func showPopover() {
            
        let myViewController = storyboard?.instantiateViewController(withIdentifier: "popupController") as! PopUpVC
            
        myViewController.preferredContentSize = CGSize(width: 350, height: 200)
        myViewController.modalPresentationStyle = .popover
    
        let currColor = UserDefaults.standard.integer(forKey: "Current Color")
        myViewController.tipText = messages[currColor]

        let popOver = myViewController.popoverPresentationController
                popOver?.delegate = self
        UIView.animate(withDuration: 1, animations: {
            self.gifView.alpha = 0.7
        })

    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            UIView.animate(withDuration: 0.5, animations: {
                self.present(myViewController, animated: true, completion: nil)
            })
        }
                popOver?.permittedArrowDirections = .down
                popOver?.sourceView = self.view
        
        var passthroughViews: [AnyObject]?
        passthroughViews = [infoButton]
        myViewController.popoverPresentationController?.passthroughViews = (NSMutableArray(array: passthroughViews!) as! [UIView])
    
        popOver?.sourceRect = infoButton.frame
    }
        
             
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}

class CustomAnimatedView: UIView, GIFAnimatable {
  public lazy var animator: Animator? = {
    return Animator(withDelegate: self)
  }()

  override public func display(_ layer: CALayer) {
    updateImageIfNeeded()
  }
}
