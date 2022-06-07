//
//  Created by Claire Wu on 3/10/20.
//  Copyright © 2022 Claire Wu. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController {

    @IBOutlet weak var tip: UILabel!
    var tipText: String = "Default"
    // var delegate: SetTipText?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tip.text = tipText

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
