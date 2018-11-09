//
//  ReportsViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 01/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

// Required Kits
import UIKit
import CoreData

// Structure of the Tech Report Model
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

// Structure of the Technical Reports JSON Data
struct technicalReports: Decodable {
    let techreports: [techReport]
}

// Global References to the App Delegate and NS Managed Object Context
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var context: NSManagedObjectContext?

// Array to store the IDs of the reports marked as a favourite
var favourites: [String] = []

class ReportsViewController: UITableViewController {
    
    // Outlet for the table view
    @IBOutlet var reportsTable: UITableView!
    
    // Dictionary to store arrays of reports keyed by their Year
    // i.e. reportsByYear[2018][0] = A report
    var reportsByYear: Dictionary<String, [techReport]> = [:]
    
    // Global Variables to store the current Year Key and Array Index of the selected report
    var currentYear: String = ""
    var currentReport = -1
    
    // Array to store the strings of the range of years of the reports
    var years: [String] = []
    
    // URL of the Data Endpoint
    let reportsURLString: String = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/techreports/data.php?class=techreports"
    
    // Called when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign the context
        context = appDelegate.persistentContainer.viewContext
        
        // Get the report JSON from the web API
        getReportJSON()
        
        // Get the favourites from the Core Data
        getFavourites()
  
        // Reload the table data
        reportsTable.reloadData()
    }
    
    // Called when the view is about to come back on to the screen
    override func viewWillAppear(_ animated: Bool) {
        // Update the table with latest favourites
        reportsTable.reloadData()
    }
    
    // Gets the Reports JSON from the weblink and sorts them to be keyed by Year
    func getReportJSON() {
        // Is the string a valid URL?
        if let url = URL(string: reportsURLString) {
            // Session to coordinate network data transfer tasks
            let session = URLSession.shared
            
            // Attempts to retreive contents of specified URL
            session.dataTask(with: url) { (data, response, err) in
                
                // Assign the data to jsonData or return
                guard let jsonData = data else {return}
                
                do {
                    // Attempt to decode JSON with our provided structures
                    let decoder = JSONDecoder()
                    let reportList = try decoder.decode(technicalReports.self, from: jsonData)
                    
                    // Dictionary store arrays of reports, keyed by Year
                    var reportsByYear: Dictionary<String, [techReport]> = [:]
                    
                    // Array to store the available Year strings across all the reports
                    var years: [String] = []
                    
                    // For all the retreived reports
                    for report in reportList.techreports {
                        // Check if the year has been added to the years array and dictionary
                        // If it hasn't been, add it
                        let yearAdded = years.contains { $0 == report.year }
                        if yearAdded == false {
                            years.append(report.year)
                            reportsByYear[report.year] = []
                        }
                        
                        // Append the report to the relevant dictionary array
                        reportsByYear[report.year]?.append(report)
                    }
                    
                    // Sort the years - this is so the sections can iterate over the years in order
                    years = years.sorted(by: { $0 > $1 })
                    
                    // Get back to the main queue
                    DispatchQueue.main.async {
                        // Set the variables
                        self.years = years
                        self.reportsByYear = reportsByYear
                        // Reload the table
                        self.reportsTable.reloadData()
                        
                    }
                } catch let jsonErr {
                    print("Error decoding JSON.", jsonErr)
                }
                }.resume()
        }
    }

    // Gets the IDs of the favourite reports from Core Data
    func getFavourites() {
        // Initially, reset the favourites array
        favourites = []
        
        // Create a Fetch Request for the Favourites
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.returnsObjectsAsFaults = false

        do {
            // Try Fetching the Core Data Favourites
            let results = try context?.fetch(request)
            
            // For each record result, append the ID string value to the favourites array
            for result in results as! [NSManagedObject] {
                let id: String = result.value(forKey: "id") as! String
                favourites.append(id)
            }
        } catch {
            print("Fetching CoreData Favourites Failed.")
        }
        
    }
 
    // The number of sections in the table is determiend by the Number of different Report Years
    override func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }

    // The title of the section is the corresponding Year sharing the the section index
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(years[section])"
    }
    
    // The number of rows in a section is determined by the number of reports associated with its year section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportsByYear[years[section]]?.count ?? 0
    }
    
    // Adjust each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Year Key and Report Index
        let year = years[indexPath.section]
        let row = indexPath.row
        
        // Set the title and authors
        cell.textLabel?.text = reportsByYear[year]?[row].title
        cell.detailTextLabel?.text = reportsByYear[year]?[row].authors
        
        // Produce the CoreData ID
        let reportYear: String = (reportsByYear[year]?[row].year)!
        let reportId: String = (reportsByYear[year]?[row].id)!
        let reportCoreId = "\(reportYear)-\(reportId)"
        
        cell.accessoryType = .none
        
        // If our ID is in the favourties, add a checkmark
        for favouriteId in favourites {
            if favouriteId == reportCoreId {
                print("Match")
                cell.accessoryType = .checkmark
                break
            }
        }
        return cell
    }
    
    // When we click a row, set the current year and report based on the index of the section and row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentYear = years[indexPath.section]
        currentReport = indexPath.row
        
        // Segue to the report view controller
        self.performSegue(withIdentifier: "to Report", sender: self)
    }
    
    // Called when about peform segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we are going to view a report, send the reports data to the view
        if segue.identifier == "to Report" {
            let viewController = segue.destination as! ViewController
            let report: techReport = reportsByYear[currentYear]?[currentReport] ?? viewController.report
            viewController.report = report;
        }
    }
}
