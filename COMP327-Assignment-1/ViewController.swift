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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var favouriteSwitch: UISwitch!
    @IBAction func favouriteSwitch(_ sender: Any) {
        let isFavourite = favouriteSwitch.isOn

        let reportYear = reportsByYear[currentYear]?[currentReport].year
        let reportId = reportsByYear[currentYear]?[currentReport].id
        let reportCoreId = "\(reportYear!)-\(reportId!)"

        if isFavourite == true {
            let newFavourite = NSEntityDescription.insertNewObject(forEntityName: "Favourites", into: context!) as! Favourites
            newFavourite.id = reportCoreId

        } else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
            request.returnsObjectsAsFaults = false
            // Set the sort descriptor
            request.sortDescriptors?.append(NSSortDescriptor(key: "creationDate", ascending: true))
            
            do {
                let results = try context?.fetch(request)
                if (results?.count)! > 0 {
                    for result in results as! [NSManagedObject] {
                        let id: String = result.value(forKey: "id") as! String
                        if (id == reportCoreId) {
                            context?.delete(result)
                        }
                    }
                }
            } catch {
                print("Couldn't fetch results")
            }
        }
        
        do {
            try context?.save()
        } catch {
            print("there was an error")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = reportsByYear[currentYear]?[currentReport].title
        authorLabel.text = reportsByYear[currentYear]?[currentReport].authors
        let abstract = reportsByYear[currentYear]?[currentReport].abstract ?? "Empty"
        
        var finalAbstract = ""
        if (abstract == "Empty") {
            finalAbstract = "No abstract available."
        } else {
            finalAbstract = santiseText(text: abstract)
        }
        
    
        
        let owner = reportsByYear[currentYear]?[currentReport].owner ??  "None"
        let lastModified = reportsByYear[currentYear]?[currentReport].lastModified ?? "None"
        let comment = reportsByYear[currentYear]?[currentReport].comment ?? "None"
        
        abstractLabel.text = finalAbstract
        ownerLabel.text = "Owner: \(owner)"
        lastModifiedLabel.text = "Last Modified: \(lastModified)"
        commentLabel.text = "Comment: \(comment)"
        
        if isFavouriteCheck() == true {
            favouriteSwitch.setOn(true, animated: false)
        }

    }
    
    func isFavouriteCheck() -> Bool {
        let reportYear = reportsByYear[currentYear]?[currentReport].year
        let reportId = reportsByYear[currentYear]?[currentReport].id
        let reportCoreId = "\(reportYear!)-\(reportId!)"
        
        for favouriteId in favourites {
            if favouriteId == reportCoreId {
                return true
            }
        }
        return false
    }
    
    func santiseText(text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\r\n", with: " ", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\n\r", with: " ", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\n", with: " ", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\r", with: " ", options: .regularExpression, range: nil)

    }
        
}

