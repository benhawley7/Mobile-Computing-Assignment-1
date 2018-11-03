//
//  ReportsViewController.swift
//  COMP327-Assignment-1
//
//  Created by Ben Hawley on 01/11/2018.
//  Copyright © 2018 Ben Hawley. All rights reserved.
//

import UIKit

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


var currentYear: String = ""
var currentReport = -1

var years: [String] = []
var reportsByYear: Dictionary<String, [techReport]> = [:]
//var reports: [techReport] = []
class ReportsViewController: UITableViewController {
    var reports: [techReport] = []
    @IBOutlet var reportsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getReportJSON()
        
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
 
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        cell.accessoryType = .checkmark
        // Configure the cell...
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
