//
//  ViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 01/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var abstractLabel: UILabel!
    //    @IBOutlet weak var authorLabel: UILabel!
//    @IBOutlet weak var abstractLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentYear)
        print(currentReport)
        titleLabel.text = reportsByYear[currentYear]?[currentReport].title
        authorLabel.text = reportsByYear[currentYear]?[currentReport].authors
        abstractLabel.text = reportsByYear[currentYear]?[currentReport].abstract ?? "No abstract available"
//        titleLabel.sizeToFit()
//        authorLabel.sizeToFit()
//        abstractLabel.sizeToFit()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

