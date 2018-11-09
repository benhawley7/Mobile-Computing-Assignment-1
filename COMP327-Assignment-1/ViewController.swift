//
//  ViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 01/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

import UIKit
import PDFKit
import CoreData

class ViewController: UIViewController, UIScrollViewDelegate {

    // Outlets for Labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    
    // Initialise Empty Tech Report, will be overwritten to current
    var report = techReport(year: "", id: "", owner: nil, authors:"", title: "", abstract: nil, pdf: nil, comment: nil, lastModified: "")

    
    // Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title and Author are never Nil - simply assign
        titleLabel.text = report.title
        authorLabel.text = report.authors
        
        // Abstract can be nil - if nil, set to empty.
        let abstract: String? = report.abstract
        
        // Set the abstract
        var finalAbstract = ""
        if (abstract == nil) {
            // Have no abstract? Tell the user that.
            finalAbstract = "No abstract available."
        } else {
            // If we have an abstract, lets sanitise it to remove Markup
            finalAbstract = santiseText(text: abstract!)
        }
        abstractLabel.text = finalAbstract
        
        // No PDF URL? Hide the button.
        if report.pdf == nil {
            pdfButton.isHidden = true
        }
        
        // Format Last Modified
        let lastModified = report.lastModified
        let formattedDate = dateFormat(dateString: lastModified)
        lastModifiedLabel.text = "Last Modified: \(formattedDate)"

        // Owner and Comment can all be Nil
        // Make sure we handle that case
        let owner = report.owner ??  "None"
        let comment = report.comment ?? "None"
        ownerLabel.text = "Owner: \(owner)"
        commentLabel.text = "Comment: \(comment)"
        
        // Is the current report a favourite?
        if isFavouriteCheck() == true {
            // If it is, set the switch on!
            favouriteSwitch.setOn(true, animated: false)
        } else {
            // It is not a favourite
            favouriteSwitch.setOn(false, animated: false)
        }
    }
    
    // Action for when the Favourite Switch is pressed
    @IBAction func favouriteSwitch(_ sender: Any) {
        let isFavourite = favouriteSwitch.isOn
        
        // Construct the favourite ID
        let reportYear = report.year
        let reportId = report.id
        let reportCoreId = "\(reportYear)-\(reportId)"
        
        // If it's a favourite now, insert the ID into CoreData
        if isFavourite == true {
            let newFavourite = NSEntityDescription.insertNewObject(forEntityName: "Favourites", into: context!) as! Favourites
            newFavourite.id = reportCoreId
            favourites.append(reportCoreId)
            
        } else {
            // It's not a favourite. Request all the favourites
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
            request.returnsObjectsAsFaults = false
            // Set the sort descriptor
            request.sortDescriptors?.append(NSSortDescriptor(key: "creationDate", ascending: true))
            
            do {
                // Get the results
                let results = try context?.fetch(request)
                
                // If we have results
                if (results?.count)! > 0 {
                    // If a result matches our ID, delete it
                    for result in results as! [NSManagedObject] {
                        let id: String = result.value(forKey: "id") as! String
                        if (id == reportCoreId) {
                            context?.delete(result)
                        }
                    }
                }
                
                // Remove from the array
                favourites = favourites.filter {$0 != reportCoreId}
            } catch {
                print("Couldn't fetch results")
            }
        }
        
        do {
            try context?.save()
        } catch {
            print("Error saving CoreData changes")
        }
        print(favourites)
    }
    
    // Function to check if the current report is a favourite
    func isFavouriteCheck() -> Bool {
        let reportYear = report.year
        let reportId = report.id
        let reportCoreId = "\(reportYear)-\(reportId)"
        
        for favouriteId in favourites {
            if favouriteId == reportCoreId {
                return true
            }
        }
        return false
    }
    
    // Function to remove Markup language from text
    func santiseText(text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespaces)
//            .replacingOccurrences(of: "\r", with: " ", options: .regularExpression, range: nil)

    }
    
    func dateFormat(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy, HH:mm:ss"
        
        guard let date = dateFormatterGet.date(from: dateString) else {
            return "Invalid Date."
        }
        return dateFormatterPrint.string(from: date)
    }
    
    // Send the PDF URL to the PDF View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to PDF" {
            let pdfViewController = segue.destination as! PDFViewController
            pdfViewController.url = report.pdf
        }
    }
        
}

