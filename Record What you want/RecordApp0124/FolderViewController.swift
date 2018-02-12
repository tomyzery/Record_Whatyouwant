//
//  FolderViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 27..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController  , UITableViewDataSource , UITableViewDelegate{
    
    
    var folderNameList : [String]? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! FileViewController
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)!
        let selectedFileHeader = folderNameList![indexPath.row]
        nextVC.FileHeader = selectedFileHeader
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.folderList = self.folderNameList!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // 한번 만들면 이후로 다시 만들지 않게 if문으로 수정
        
        
        let fileManager = FileManager()
        
       
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList")
        let documentsDirectory4 = documentsDirectory.appendingPathComponent("mp3List")
        let documentsDirectory3 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent("Human Respiratory")
        
        print("This project path to Docunets or the other Things :\(documentsDirectory2)")
        
        do {
            try fileManager.createDirectory(atPath: documentsDirectory2.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        do {
            try fileManager.createDirectory(atPath: documentsDirectory4.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        
        do {
            try fileManager.createDirectory(atPath: documentsDirectory3.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if folderNameList == nil {
            checkFolderList()
        } else {
            
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        
        //tableView.setEditing(false, animated: animated)
        
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
    
    
    
    
    
    @objc func actionsample(_ sender: UIButton){
        
        let alert = UIAlertController(title: "New Folder Name", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated:false)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return folderNameList!.count
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell1", for: indexPath)
        cell.imageView?.image = UIImage(named:"folder")
        cell.textLabel?.text = folderNameList?[indexPath.row]
        //cell.textLabel!.textAlignment = NSTextAlignment.Center
      
        
        
        return cell
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Documents Folder"
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        // Return false if you do not want the item to be re-orderable.
        return true
        
    }
    
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = folderNameList!.remove(at: indexPath.row)
            // Delete the row from the data source
            

            
             let fileManager = FileManager()
             let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
             
             let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
             
             let dataPath = documentsDirectory.appendingPathComponent(item)
             
             do {    // removeItem(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
             try fileManager.removeItem(at: dataPath)
             } catch let error as NSError {
             print("Error creating directory: \(error.localizedDescription)")
             }
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
          

            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }

    }
    
  
    
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let saveChanges = self.folderNameList![fromIndexPath.row]
        let removeItem = self.folderNameList!.remove(at: fromIndexPath.row)
        self.folderNameList!.insert(saveChanges, at : to.row)
        
    
         // edit -> move ///////////////////////////////////////////////////////////////////////////////////////////////
        
         let fileManager = FileManager()
        
        
         
         let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
         
         let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
        
         let keep = documentsDirectory.appendingPathComponent(saveChanges)
         let temp = documentsDirectory.appendingPathComponent(removeItem)
        
         
         do { // removeItem(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
         try fileManager.removeItem(at: temp)
         } catch let error as NSError {
         print("Error creating directory: \(error.localizedDescription)")
         }
        
         
         do { // removeItem(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
         try fileManager.createDirectory(at: keep, withIntermediateDirectories: false, attributes: nil)
         } catch let error as NSError {
         print("Error creating directory: \(error.localizedDescription)")
         
         }
   
        self.tableView.reloadData()
      
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    
    
    @IBAction func folderPlusBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Folder Name", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            
            action -> Void in
            
            let textField = alert.textFields![0] as UITextField
            print(textField.text!)
            
            
            
            let folderName = textField.text!
            
            let fileManager = FileManager()
            let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
            
            let dataPath = documentsDirectory.appendingPathComponent(folderName)
            
            do {
                try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
            
            self.folderNameList?.append(folderName)
            self.tableView.reloadData()
            
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
            print("cancel")
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated:true , completion: nil)
        
  
        
    }
    

    
    func checkFolderList() {
        
        let fileManager = FileManager.default
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
        
        var folderNameList: [String] = []
        
        do{
            folderNameList = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            
            
        } catch {
            print("error")
            
        }
        
        self.folderNameList = folderNameList
        self.tableView.reloadData()
       
    }
    
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */






