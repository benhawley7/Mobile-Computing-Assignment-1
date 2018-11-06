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
    // Outlet for the PDFView
    @IBOutlet weak var pdfView: PDFView!
    
    // Outlet for the loading spinner
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Called when the view load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start activity indicator and set it to disappear when stopped
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.startAnimating()
        // Get the PDF URL
        let url = reportsByYear[currentYear]?[currentReport].pdf
        // If the URL is nil, backout
        if url == nil {
            return
        }
        
        // Perform this action in the background, so to not block the interface
        DispatchQueue.global(qos: .background).async {
            // Get the Document from the URL and assign it as the PDF views document
            let document = PDFDocument(url: url!)
       
            DispatchQueue.main.async {
                self.pdfView.autoScales = true
                self.pdfView.document = document
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
