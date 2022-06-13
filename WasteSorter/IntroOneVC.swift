//
//  IntroOneVC.swift
//  WasteSorter
//
//  Created by Claire Wu on 6/12/22.
//  Copyright © 2022 Claire Wu. All rights reserved.
//

import UIKit

class IntroOneVC: UIViewController {
    
    @IBOutlet weak var tutorialView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialView.layer.cornerRadius = 20
        tutorialView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch: UITouch? = touches.first
        if touch?.view != self.tutorialView {
            weak var parentController = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "introTwoVC")
                vc.modalPresentationStyle = .popover
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                parentController?.present(vc, animated: true, completion: nil)
            })
        }
    }
}
