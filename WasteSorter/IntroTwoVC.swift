//
//  IntroTwoVC.swift
//  WasteSorter
//
//  Created by Claire Wu on 6/12/22.
//  Copyright © 2022 Claire Wu. All rights reserved.
//

import UIKit

class IntroTwoVC: UIViewController {
    
    @IBOutlet weak var tutorialTwoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialTwoView.layer.cornerRadius = 20
        tutorialTwoView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view != self.tutorialTwoView {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
