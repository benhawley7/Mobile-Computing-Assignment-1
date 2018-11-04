//
//  PDFViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 04/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = reportsByYear[currentYear]?[currentReport].pdf
        let document = PDFDocument(url: url!)
        pdfView.autoScales = true
        pdfView.document = document
    }
}
