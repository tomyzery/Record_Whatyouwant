//
//  FileViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 27..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit


class FileViewController: UIViewController  ,UITableViewDataSource, UITableViewDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fileRecordedList : [String] = []
    var fileNonRecordedList : [String] = []
    
    // 이 코드에서 앞에 Folder scene의 이름을 받아 왔다. 따로 delegate 없이 사용 가능
    var FileHeader: String = ""
    
    @IBOutlet weak var folderName: UINavigationItem!
    
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        if folderName != nil {
            folderName.title = FileHeader
        }
        
    
        checkFileRecordedList()
        checkFileNonRecordedList()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager()
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
        
        let fileRecorded = documentsDirectory2.appendingPathComponent("Recorded")
        
        let fileNonRecorded = documentsDirectory2.appendingPathComponent("Non Recorded")
        
        let samplePDF1 = documentsDirectory2.appendingPathComponent("Recorded").appendingPathComponent("Human Respiratory 2017.06.14")
        
        let samplePDF2 = documentsDirectory2.appendingPathComponent("Recorded").appendingPathComponent("Human Respiratory 2017.06.07")
        
        let samplePDF3 = documentsDirectory2.appendingPathComponent("Non Recorded").appendingPathComponent("Human Respiratory 2017.06.21")
        
        let samplePDF4 = documentsDirectory2.appendingPathComponent("Non Recorded").appendingPathComponent("Human Respiratory 2017.06.28")
        
        let samplePDF5 = documentsDirectory2.appendingPathComponent("Non Recorded").appendingPathComponent("Human Respiratory 2017.07.05")
        
        let samplePDF6 = documentsDirectory2.appendingPathComponent("Non Recorded").appendingPathComponent("Human Respiratory 2017.07.12")
        
        print("This project path to Docunets or the other Things :\(documentsDirectory2)")
        

        do {
            try fileManager.createDirectory(atPath: fileRecorded.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        do {
            try fileManager.createDirectory(atPath: fileNonRecorded.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        do {
            try fileManager.createDirectory(atPath: samplePDF3.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF4.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF5.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF6.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF1.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF2.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        checkFileRecordedList()
        checkFileNonRecordedList()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        
        let status = navigationItem.rightBarButtonItem?.title
        
        
        if status == "Edit" {
            
            tableView.setEditing(true, animated: animated)
            
            tableView.isEditing = true
            
            navigationItem.rightBarButtonItem?.title = "Done"
            
        }
            
        else {
            
            tableView.setEditing(false, animated: animated)
            
            tableView.isEditing = false
            
            navigationItem.rightBarButtonItem?.title = "Edit"
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // table
    
    // MARK: - Table view data source
    
    

    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return fileRecordedList.count
        } else {
            return fileNonRecordedList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell2", for: indexPath)
        
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(named:"pdf")
            cell.textLabel?.text = fileRecordedList[indexPath.row]
        } else {
            cell.imageView?.image = UIImage(named:"pdf")
            cell.textLabel?.text = fileNonRecordedList[indexPath.row]
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                fileRecordedList.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                fileNonRecordedList.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if tableView.numberOfSections == 0 {
            let saveChanges = fileRecordedList[fromIndexPath.row]
            fileRecordedList.remove(at: fromIndexPath.row)
            fileNonRecordedList.insert(saveChanges, at : to.row)
        } else  {
            let saveChanges = fileNonRecordedList[fromIndexPath.row]
            fileRecordedList.remove(at: fromIndexPath.row)
            fileNonRecordedList.insert(saveChanges, at : to.row)
        }
        
    }

    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Recorded"
        } else {
            return "Non Recorded"
        }
        
    }
    
    @IBAction func webCallBtn(_ sender: UIButton) {
        
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Open by Web browser", style: .default) { action -> Void in
            
            if let url = URL(string: "https://www.google.com") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Open by URL", style: .default) { action -> Void in
            
            
            let alert = UIAlertController(title: " Type URL ", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addTextField()
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated:false)
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func checkFileRecordedList() {
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
        let fileRecorded = documentsDirectory2.appendingPathComponent("Recorded")
        
        var fileRecordedList: [String] = []
        
        do{
            fileRecordedList = try fileManager.contentsOfDirectory(atPath: fileRecorded.path)
            
            
        } catch {
            print("error")
            
        }
        
        self.fileRecordedList = fileRecordedList

    }
    



func checkFileNonRecordedList() {
    
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
    let fileNonRecorded = documentsDirectory2.appendingPathComponent("Non Recorded")
    
    var fileNonRecordedList: [String] = []
    
    do{
        fileNonRecordedList = try fileManager.contentsOfDirectory(atPath: fileNonRecorded.path)
        
        
    } catch {
        print("error")
        
    }
    
    self.fileNonRecordedList = fileNonRecordedList
    
}



    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}

