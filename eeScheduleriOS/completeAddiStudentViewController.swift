//
//  completeAddiStudentViewController.swift
//  eeScheduleriOS
//
//

import UIKit
import M13Checkbox


class completeAddiStudentViewController: UIViewController {
    @IBOutlet weak var check: M13Checkbox!
    var finishLoad = false
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
        print ("success for check")
        if finishLoad == false {
            check.setCheckState(.checked, animated: true)
            let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
                self.performSegue(withIdentifier: "finishedAdding", sender: self )
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupView() {
        check.boxType = .circle
        check.stateChangeAnimation = .spiral
        check.animationDuration = 2.0
        check.checkmarkLineWidth = 10.0
        check.tintColor = .green
    }
}

