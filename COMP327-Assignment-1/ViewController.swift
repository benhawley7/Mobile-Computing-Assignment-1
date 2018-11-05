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


    
    // Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let report = (reportsByYear[currentYear]?[currentReport])!
        
        // Title and Author are never Nil - simply assign
        titleLabel.text = report.title
        authorLabel.text = report.authors
        
        // Abstract can be nil - if nil, set to empty.
        let abstract = report.abstract ?? "Empty"
        
        var finalAbstract = ""
        if (abstract == "Empty") {
            finalAbstract = "No abstract available."
        } else {
            // If we have an abstract, lets sanitise it to remove Markup
            finalAbstract = santiseText(text: abstract)
        }
        abstractLabel.text = finalAbstract
        
        if report.pdf == nil {
            pdfButton.isHidden = true
        }
        
        // Owner, Last Modified and Comment can all be Nil
        // Make sure we handle that case
        let owner = report.owner ??  "None"
        let lastModified = report.lastModified 
        let comment = report.comment ?? "None"
        ownerLabel.text = "Owner: \(owner)"
        lastModifiedLabel.text = "Last Modified: \(lastModified)"
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
        
        let report = (reportsByYear[currentYear]?[currentReport])!
        
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
        let report = (reportsByYear[currentYear]?[currentReport])!
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
        
}

