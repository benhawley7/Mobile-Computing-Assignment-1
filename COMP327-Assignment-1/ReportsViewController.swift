//
//  ReportsViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 01/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

import UIKit
import CoreData

struct techReport: Decodable {
    let year: String
    let id: String
    let owner: String?
    let authors: String
    let title: String
    let abstract: String?
    let pdf: URL?
    let comment: String?
    let lastModified: String
}

struct technicalReports: Decodable {
    let techreports: [techReport]
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
var context: NSManagedObjectContext?


var currentYear: String = ""
var currentReport = -1

var years: [String] = []
var reportsByYear: Dictionary<String, [techReport]> = [:]
var favourites: [String] = []
//var reports: [techReport] = []
class ReportsViewController: UITableViewController {
   
    

    var reports: [techReport] = []
    @IBOutlet var reportsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded.")
        context = appDelegate.persistentContainer.viewContext
        getReportJSON()
        getFavourites()
        print(favourites)
        reportsTable.reloadData()
    }

    func getFavourites() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.returnsObjectsAsFaults = false
        
        // Reset the favourites array
        favourites = []
        
        do {
            let results = try context?.fetch(request)
            for result in results as! [NSManagedObject] {
                let id: String = result.value(forKey: "id") as! String
                favourites.append(id)
            }
        } catch {
            print("couldn't fetch results")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("About to appear")
        getFavourites()
        reportsTable.reloadData()
    }

    func getReportJSON() {
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/techreports/data.php?class=techreports") {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {return}
                
                do{
                    let decoder = JSONDecoder()
                    //decoder.dateDecodingStrategy = .
                    let reportList = try decoder.decode(technicalReports.self, from: jsonData)
                    
 
                    //Get back to the main queue
                    DispatchQueue.main.async {
        
                        var reports: [techReport] = []
                        
                        for report in reportList.techreports {
                            let hasYear = years.contains { $0 == report.year }
                            if hasYear == false {
                                years.append(report.year)
                            }
                            reports.append(report)
                        }
                        
                        let sortedYears = years.sorted(by: { $0 > $1 })
                        for year in sortedYears {
                            reportsByYear[year] = []
                        }
                        
                        years = sortedYears
                        
                        for report in reportList.techreports {
                            reportsByYear[report.year]?.append(report)
                        }
                        
                        self.reportsTable.reloadData()
            
                    }
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                
                }.resume()
            
        }
    }
 

    override func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportsByYear[years[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(years[section])"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentYear = years[indexPath.section]
        currentReport = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let year = years[indexPath.section]
        let row = indexPath.row
        cell.textLabel?.text = reportsByYear[year]?[row].title
        cell.detailTextLabel?.text = reportsByYear[year]?[row].authors
        
        let reportYear: String = (reportsByYear[year]?[row].year)!
        let reportId: String = (reportsByYear[year]?[row].id)!
        let reportCoreId = "\(reportYear)-\(reportId)"
        
        for favouriteId in favourites {
            if favouriteId == reportCoreId {
                print("Match")
                cell.accessoryType = .checkmark
                break
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }
}
