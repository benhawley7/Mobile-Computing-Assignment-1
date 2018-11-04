//
//  PDFViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 04/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

// Required Kits
import UIKit
import PDFKit

class PDFViewController: UIViewController {
    // Outelt for the PDFView
    @IBOutlet weak var pdfView: PDFView!
    
    // Called when the view load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the PDF URL
        let url = reportsByYear[currentYear]?[currentReport].pdf
        
        // If the URL is nil, backout
        if url == nil {
            return
        }
        
        // Get the Documetn from the URL and assign it as the PDF views document
        let document = PDFDocument(url: url!)
        pdfView.autoScales = true
        pdfView.document = document
    }
}
